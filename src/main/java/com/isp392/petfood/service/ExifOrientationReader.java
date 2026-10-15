package com.isp392.petfood.service;

// Đọc thẻ Orientation (0x0112) trong khối EXIF của file JPEG.
// Ảnh chụp bằng điện thoại thường lưu điểm ảnh nằm ngang rồi ghi "hãy xoay 90°" vào thẻ này;
// nếu bỏ qua thì ảnh lên web bị nằm ngang (script Python của nhóm xử lý việc này bằng ImageOps.exif_transpose).
// Giá trị: 1 = giữ nguyên, 2..8 = lật/xoay. Không phải JPEG, không có EXIF hoặc dữ liệu hỏng -> trả về 1.
final class ExifOrientationReader {

    private static final int TAG_ORIENTATION = 0x0112;

    private ExifOrientationReader() {
    }

    static int read(byte[] data) {
        try {
            return parseJpeg(data);
        } catch (RuntimeException e) {     // ví dụ chỉ số vượt mảng do file hỏng: coi như không xoay
            return 1;
        }
    }

    // JPEG = chuỗi các đoạn: FF <mã đoạn> <độ dài 2 byte, big-endian, gồm cả 2 byte độ dài> <dữ liệu>.
    // EXIF nằm trong đoạn APP1 (FF E1), bắt đầu bằng "Exif\0\0", phía sau là một cấu trúc TIFF.
    private static int parseJpeg(byte[] d) {
        if (d.length < 4 || (d[0] & 0xFF) != 0xFF || (d[1] & 0xFF) != 0xD8) {
            return 1;                                   // không có SOI (FF D8): không phải JPEG
        }
        int pos = 2;
        while (pos + 4 <= d.length) {
            if ((d[pos] & 0xFF) != 0xFF) {
                return 1;
            }
            int marker = d[pos + 1] & 0xFF;
            if (marker == 0xFF) {                       // byte đệm FF FF: bỏ qua một byte
                pos++;
                continue;
            }
            if (marker == 0xDA || marker == 0xD9) {     // SOS (bắt đầu dữ liệu ảnh) hoặc EOI: không còn đoạn EXIF
                return 1;
            }
            int length = readU16(d, pos + 2, false);
            int start = pos + 4;                        // vị trí byte dữ liệu đầu tiên của đoạn
            int end = Math.min(d.length, pos + 2 + length);
            if (marker == 0xE1 && isExifHeader(d, start, end)) {
                return orientationFromTiff(d, start + 6, end);
            }
            pos += 2 + length;
        }
        return 1;
    }

    private static boolean isExifHeader(byte[] d, int start, int end) {
        return start + 6 <= end
                && d[start] == 'E' && d[start + 1] == 'x' && d[start + 2] == 'i' && d[start + 3] == 'f'
                && d[start + 4] == 0 && d[start + 5] == 0;
    }

    // TIFF: 2 byte thứ tự byte ("II" little-endian / "MM" big-endian), 2 byte số 42,
    // 4 byte vị trí IFD0 (tính từ đầu TIFF). IFD0 = 2 byte số mục + mỗi mục 12 byte:
    // tag(2) kiểu(2) số phần tử(4) giá trị(4). Orientation kiểu SHORT nên giá trị nằm ở 2 byte đầu ô giá trị.
    private static int orientationFromTiff(byte[] d, int tiff, int end) {
        if (tiff + 8 > end) {
            return 1;
        }
        boolean littleEndian;
        if (d[tiff] == 'I' && d[tiff + 1] == 'I') {
            littleEndian = true;
        } else if (d[tiff] == 'M' && d[tiff + 1] == 'M') {
            littleEndian = false;
        } else {
            return 1;
        }
        long ifdOffset = readU32(d, tiff + 4, littleEndian);
        if (ifdOffset < 8 || tiff + ifdOffset + 2 > end) {
            return 1;
        }
        int ifd = (int) (tiff + ifdOffset);
        int entryCount = readU16(d, ifd, littleEndian);
        for (int i = 0; i < entryCount; i++) {
            int entry = ifd + 2 + i * 12;
            if (entry + 12 > end) {
                return 1;
            }
            if (readU16(d, entry, littleEndian) == TAG_ORIENTATION) {
                int value = readU16(d, entry + 8, littleEndian);
                return (value >= 1 && value <= 8) ? value : 1;
            }
        }
        return 1;
    }

    private static int readU16(byte[] d, int i, boolean littleEndian) {
        int b0 = d[i] & 0xFF;
        int b1 = d[i + 1] & 0xFF;
        return littleEndian ? (b1 << 8) | b0 : (b0 << 8) | b1;
    }

    private static long readU32(byte[] d, int i, boolean littleEndian) {
        long b0 = d[i] & 0xFF;
        long b1 = d[i + 1] & 0xFF;
        long b2 = d[i + 2] & 0xFF;
        long b3 = d[i + 3] & 0xFF;
        return littleEndian
                ? (b3 << 24) | (b2 << 16) | (b1 << 8) | b0
                : (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
    }
}
