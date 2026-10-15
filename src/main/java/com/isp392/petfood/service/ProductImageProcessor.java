package com.isp392.petfood.service;

import com.isp392.petfood.exception.InvalidImageException;
import org.springframework.stereotype.Component;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageReadParam;
import javax.imageio.ImageReader;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.ImageOutputStream;
import javax.imageio.stream.MemoryCacheImageInputStream;
import javax.imageio.stream.MemoryCacheImageOutputStream;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Set;

// Chuẩn hoá ảnh sản phẩm nhân viên tải lên, cùng thông số với script claude/process_images.py của nhóm:
//   - chỉ nhận JPG, PNG, WEBP; kiểm tra bằng nội dung file, không tin đuôi file hay Content-Type
//   - nền trong suốt (PNG) -> nền trắng
//   - xoay đúng chiều theo EXIF (ảnh chụp điện thoại)
//   - thu nhỏ cạnh dài nhất về 900px, không phóng to ảnh nhỏ
//   - lưu JPG chất lượng 82, progressive
// Chỉ dùng thư viện có sẵn của JDK (javax.imageio, java.awt). WEBP và JPEG hệ màu CMYK đọc được nhờ
// plugin TwelveMonkeys khai báo trong pom.xml (thiếu plugin thì các file đó bị báo "không hỗ trợ").
@Component
public class ProductImageProcessor {

    public static final int MAX_SIDE = 900;              // --size 900
    public static final float JPEG_QUALITY = 0.82f;      // --quality 82
    public static final int MIN_SIDE = 300;              // ảnh nhỏ hơn bị vỡ khi xem ở trang chi tiết
    public static final long MAX_PIXELS = 30_000_000L;   // chặn ảnh khai báo kích thước khổng lồ (ngốn RAM)

    private static final Set<String> ACCEPTED_FORMATS = Set.of("jpeg", "jpg", "png", "webp");

    public ProductImageProcessor() {
        // Nạp các plugin đọc ảnh nằm trên classpath (TwelveMonkeys), kể cả khi chạy bằng file .war
        ImageIO.scanForPlugins();
    }

    // Nhận nội dung file gốc, trả về nội dung file JPG đã chuẩn hoá
    public byte[] toJpeg(byte[] original) {
        return toJpeg(original, MAX_SIDE, MIN_SIDE);
    }

    // Cùng các bước trên nhưng tự chọn kích thước, ví dụ ảnh đại diện khách hàng (nhỏ hơn ảnh sản phẩm)
    public byte[] toJpeg(byte[] original, int maxSide, int minSide) {
        BufferedImage image = decode(original, maxSide, minSide);
        image = flattenOnWhite(image);
        image = applyExifOrientation(image, ExifOrientationReader.read(original));
        image = shrinkToFit(image, maxSide);
        return encodeJpeg(image);
    }

    // ---------- 1. Đọc ảnh ----------
    private BufferedImage decode(byte[] data, int maxSide, int minSide) {
        try (ImageInputStream in = new MemoryCacheImageInputStream(new ByteArrayInputStream(data))) {
            Iterator<ImageReader> readers = ImageIO.getImageReaders(in);
            if (!readers.hasNext()) {
                throw new InvalidImageException("File không phải ảnh hoặc định dạng không hỗ trợ (chỉ nhận JPG, PNG, WEBP)");
            }
            ImageReader reader = readers.next();
            try {
                String format = reader.getFormatName().toLowerCase(Locale.ROOT);
                if (!ACCEPTED_FORMATS.contains(format)) {
                    throw new InvalidImageException("Không hỗ trợ ảnh " + format.toUpperCase(Locale.ROOT)
                            + ", chỉ nhận JPG, PNG, WEBP");
                }
                reader.setInput(in, true, true);

                // Đọc kích thước từ phần đầu file, chưa giải nén điểm ảnh
                int width = reader.getWidth(0);
                int height = reader.getHeight(0);
                if ((long) width * height > MAX_PIXELS) {
                    throw new InvalidImageException("Ảnh quá lớn (" + width + "×" + height
                            + " px), tối đa 30 megapixel");
                }
                if (Math.min(width, height) < minSide) {
                    throw new InvalidImageException("Ảnh quá nhỏ (" + width + "×" + height
                            + " px), cần tối thiểu " + minSide + "×" + minSide + " px");
                }

                // Ảnh rất to (ví dụ 6000px) thì đọc cách điểm để đỡ tốn RAM, vẫn giữ >= 2 lần kích thước đích
                ImageReadParam param = reader.getDefaultReadParam();
                int step = Math.max(1, Math.max(width, height) / (maxSide * 2));
                if (step > 1) {
                    param.setSourceSubsampling(step, step, 0, 0);
                }

                // File JPEG bị cắt dở vẫn "đọc được" nhưng ra ảnh xám loang lổ; bộ đọc chỉ báo qua cảnh báo
                List<String> warnings = new ArrayList<>();
                reader.addIIOReadWarningListener((source, warning) -> warnings.add(warning));
                BufferedImage image = reader.read(0, param);
                for (String warning : warnings) {
                    String w = warning.toLowerCase(Locale.ROOT);
                    if (w.contains("truncated") || w.contains("premature end")) {
                        throw new InvalidImageException("File ảnh bị thiếu dữ liệu (tải chưa hết hoặc hỏng), hãy chọn lại ảnh");
                    }
                }
                return image;
            } finally {
                reader.dispose();
            }
        } catch (InvalidImageException e) {
            throw e;
        } catch (IOException | RuntimeException e) {
            // File cắt dở, hỏng, hoặc JPEG hệ màu CMYK khi thiếu plugin
            throw new InvalidImageException("File ảnh bị lỗi hoặc không đọc được, hãy lưu lại ảnh dạng JPG/PNG rồi thử lại");
        }
    }

    // ---------- 2. Nền trắng ----------
    // Vẽ ảnh lên khung RGB nền trắng: phần trong suốt thành trắng (JPG không có kênh trong suốt),
    // đồng thời đưa mọi kiểu ảnh (bảng màu, xám, 16 bit...) về một kiểu RGB duy nhất.
    static BufferedImage flattenOnWhite(BufferedImage src) {
        BufferedImage rgb = new BufferedImage(src.getWidth(), src.getHeight(), BufferedImage.TYPE_INT_RGB);
        Graphics2D g = rgb.createGraphics();
        try {
            g.setColor(Color.WHITE);
            g.fillRect(0, 0, rgb.getWidth(), rgb.getHeight());
            g.drawImage(src, 0, 0, null);
        } finally {
            g.dispose();
        }
        return rgb;
    }

    // ---------- 3. Xoay theo EXIF ----------
    // Mỗi giá trị orientation là một phép lật/xoay. AffineTransform(m00, m10, m01, m11, m02, m12):
    //   x' = m00*x + m01*y + m02,   y' = m10*x + m11*y + m12
    static BufferedImage applyExifOrientation(BufferedImage src, int orientation) {
        if (orientation < 2 || orientation > 8) {
            return src;
        }
        int w = src.getWidth();
        int h = src.getHeight();
        AffineTransform t = switch (orientation) {
            case 2 -> new AffineTransform(-1, 0, 0, 1, w, 0);    // lật ngang
            case 3 -> new AffineTransform(-1, 0, 0, -1, w, h);   // xoay 180°
            case 4 -> new AffineTransform(1, 0, 0, -1, 0, h);    // lật dọc
            case 5 -> new AffineTransform(0, 1, 1, 0, 0, 0);     // lật theo đường chéo chính
            case 6 -> new AffineTransform(0, 1, -1, 0, h, 0);    // xoay 90° theo chiều kim đồng hồ
            case 7 -> new AffineTransform(0, -1, -1, 0, h, w);   // lật theo đường chéo phụ
            default -> new AffineTransform(0, -1, 1, 0, 0, w);   // 8: xoay 90° ngược chiều kim đồng hồ
        };
        boolean swapSides = orientation >= 5;                    // 5..8 làm ảnh đổi chiều ngang/dọc
        BufferedImage dst = new BufferedImage(swapSides ? h : w, swapSides ? w : h, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = dst.createGraphics();
        try {
            g.drawImage(src, t, null);
        } finally {
            g.dispose();
        }
        return dst;
    }

    // ---------- 4. Thu nhỏ ----------
    // Thu nhỏ một lần từ 4000px xuống 900px sẽ bị răng cưa, nên thu dần mỗi lần một nửa rồi chỉnh lần cuối.
    static BufferedImage shrinkToFit(BufferedImage src, int maxSide) {
        int w = src.getWidth();
        int h = src.getHeight();
        if (Math.max(w, h) <= maxSide) {
            return src;                                          // không phóng to ảnh nhỏ
        }
        double scale = (double) maxSide / Math.max(w, h);
        int targetW = Math.max(1, (int) Math.round(w * scale));
        int targetH = Math.max(1, (int) Math.round(h * scale));

        BufferedImage current = src;
        while (current.getWidth() / 2 >= targetW && current.getHeight() / 2 >= targetH) {
            current = resize(current, current.getWidth() / 2, current.getHeight() / 2);
        }
        if (current.getWidth() != targetW || current.getHeight() != targetH) {
            current = resize(current, targetW, targetH);
        }
        return current;
    }

    private static BufferedImage resize(BufferedImage src, int width, int height) {
        BufferedImage dst = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = dst.createGraphics();
        try {
            g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            g.drawImage(src, 0, 0, width, height, null);
        } finally {
            g.dispose();
        }
        return dst;
    }

    // ---------- 5. Ghi JPG ----------
    static byte[] encodeJpeg(BufferedImage image) {
        ImageWriter writer = ImageIO.getImageWritersByFormatName("jpeg").next();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try (ImageOutputStream ios = new MemoryCacheImageOutputStream(out)) {
            writer.setOutput(ios);
            ImageWriteParam param = writer.getDefaultWriteParam();
            param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
            param.setCompressionQuality(JPEG_QUALITY);
            param.setProgressiveMode(ImageWriteParam.MODE_DEFAULT);
            writer.write(null, new IIOImage(image, null, null), param);
        } catch (IOException e) {
            throw new UncheckedIOException("Không ghi được ảnh JPG", e);
        } finally {
            writer.dispose();
        }
        return out.toByteArray();       // đọc sau khi ios đã đóng (đã đẩy hết dữ liệu ra out)
    }
}
