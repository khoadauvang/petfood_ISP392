# Food Pet Shop – petfood-be

Đồ án ISP392 – Group 3. Spring Boot 4 + JSP (Java 21, Maven, đóng gói war), SQL Server.

## Tình trạng hiện tại – FE đọc phần này trước

**Backend đã xong.** Mọi trang trong app đều đã có file JSP chạy được: dữ liệu hiện đủ, form gửi được, lỗi báo đúng ô. Các JSP này chỉ dùng **style tạm** (CSS viết thẳng trong `<style>`) để BE test.

**Việc của FE:** làm giao diện thật trên chính các file JSP đó (bố cục, CSS, JS, responsive). Cách làm:

1. Chạy app, đăng nhập tài khoản test, mở trang cần làm (xem [Bản đồ trang](#bản-đồ-trang)).
2. Mở file JSP tương ứng, đọc xem trang đang dùng những biến `${...}`, form và nút nào.
3. Đổi HTML/CSS theo thiết kế nhưng **giữ nguyên phần "hợp đồng" với BE** (xem [Quy tắc bắt buộc](#quy-tắc-bắt-buộc-khi-sửa-jsp)).
4. Bấm thử mọi nút và form trên trang, kể cả trường hợp nhập sai, để chắc chắn vẫn chạy như trước.

Không cần sửa Java. Nếu thiết kế cần thêm dữ liệu mà model chưa có, hoặc cần đổi URL / tên field, hãy nhắn BE thay vì tự sửa controller.

## Cài đặt và chạy

### Cần có

- JDK 21
- SQL Server (chạy ở `localhost:1433`, đăng nhập bằng user `sa`)
- IDE: IntelliJ IDEA hoặc NetBeans 20 trở lên
- Không cần cài Maven: project có sẵn Maven Wrapper (`mvnw` / `mvnw.cmd`)

### 1. Tạo database

Script SQL không nằm trong repo này. Xin BE file **`FoodPetShop_FullSetup.sql`** rồi chạy nó trong SSMS / Azure Data Studio. Script này tạo database `FoodPetShop`, đủ các bảng và dữ liệu mẫu (tài khoản, 11 sản phẩm có ảnh, lô hàng, kịch bản chatbox).

> Script **xoá sạch** dữ liệu cũ rồi tạo lại. Chạy lại khi DB bị lỗi hoặc BE báo có thay đổi bảng.

App không tự tạo bảng: nếu DB thiếu bảng hoặc cột, app sẽ dừng ngay lúc khởi động với lỗi `Schema-validation`. Khi gặp lỗi đó, chạy lại script mới nhất.

### 2. Tạo file `.env`

Tạo file `.env` ở thư mục gốc project (cùng chỗ với `pom.xml`). File này đã có trong `.gitignore`, **không commit**:

```properties
DB_PASSWORD=mật_khẩu_sa_của_bạn
```

Như vậy là đủ để chạy. Các dòng dưới đây không bắt buộc, chỉ thêm khi cần test phần tương ứng (xin BE giá trị):

| Thêm vào `.env` | Bật tính năng | Không có thì |
|---|---|---|
| `spring.security.oauth2.client.registration.google.client-id=...` + `...client-secret=...` | Nút "Đăng nhập bằng Google" | Nút này tự ẩn |
| `petfood.vnpay.tmn-code=...` + `petfood.vnpay.hash-secret=...` | Thanh toán VNPay (sandbox) | Chỉ có COD, ô VNPay bị tắt |
| `spring.mail.username=...` + `spring.mail.password=...` | Gửi email (OTP quên mật khẩu, trả lời hỗ trợ) | Gửi mail báo lỗi |
| `petfood.geocoding.geoapify-api-key=...` | Tính phí ship theo khoảng cách | Phí ship luôn 30.000đ |

### 3. Chạy app

Thư mục làm việc (working directory) **phải là thư mục gốc project**, vì app đọc `.env` và lưu ảnh upload vào `./uploads` tính từ đó.

**NetBeans**

1. *File → Open Project* → chọn thư mục `petfood-be`.
2. Chuột phải project → *Properties → Actions* → chọn **Run project** → ô *Execute Goals* gõ `spring-boot:run`.
3. Bấm *Run* (F6). **Không** chọn server Tomcat/GlassFish nếu NetBeans hỏi: app tự chạy Tomcat nhúng.

**IntelliJ IDEA**

1. Mở thư mục `petfood-be`.
2. *Edit Configurations* → `PetfoodBeApplication` → *Working directory* = `$MODULE_WORKING_DIR$`.
3. Bấm ▶.

**Dòng lệnh**

```bash
./mvnw spring-boot:run        # macOS / Linux
mvnw.cmd spring-boot:run      # Windows
```

Đợi console hiện `Tomcat started on port 8080` rồi mở http://localhost:8080 (trang danh sách sản phẩm).

### Tài khoản test (từ script seed)

| Vai trò | Email | Mật khẩu | Vào trang |
|---|---|---|---|
| Admin | `admin@foodpetshop.test` | `Admin@123` | `/admin` (và mọi trang `/staff`) |
| Staff | `staff01@foodpetshop.test` … `staff03@…` | `Staff@123` | `/staff` |
| Khách | `an.nguyen@example.com` (và 6 tài khoản `@example.com` khác trong script) | `Customer@123` | `/`, giỏ hàng, đơn hàng |

Muốn có đơn hàng để làm trang đơn / trả hàng / đánh giá: đăng nhập khách → thêm vào giỏ → đặt hàng COD, rồi đăng nhập staff → `/staff/orders` → bấm lần lượt Xác nhận → Đóng gói → Giao → Hoàn tất.

## Cấu trúc thư mục – ai sửa ở đâu

```
src/main/
├── java/com/isp392/petfood/       ← BE (controller, service, repository, entity, dto...)
├── resources/
│   ├── application.properties    ← BE
│   └── static/                   ← FE: tạo thêm css/, js/, images/ ở đây (gọi bằng ${ctx}/css/..., ${ctx}/js/...)
│       └── images/products/      ← ảnh sản phẩm mẫu, KHÔNG sửa / đổi tên
└── webapp/WEB-INF/views/         ← FE: toàn bộ file .jsp
```

- Controller trả về `"product/list"` → app mở file `webapp/WEB-INF/views/product/list.jsp`.
- Sửa file JSP: lưu rồi tải lại trang là thấy, không cần chạy lại app.
- Sửa file trong `static/` (css, js): cần build lại để file được chép sang `target/` (IntelliJ: *Build → Build Project*, Ctrl+F9; NetBeans: chạy lại app), rồi tải lại trang với Ctrl+F5.
- Security đã cho phép mọi người (kể cả khách chưa đăng nhập) tải `/css/**`, `/js/**`, `/images/**`. Đặt file ở thư mục khác thì trang đăng nhập sẽ không tải được.
- Thư mục `uploads/` ở gốc project chứa ảnh nhân viên / khách tải lên lúc chạy. Không commit thư mục này.

## Quy tắc bắt buộc khi sửa JSP

Đây là phần "hợp đồng" giữa FE và BE. Làm sai thì trang vẫn hiện bình thường nhưng **bấm nút sẽ lỗi hoặc mất dữ liệu**.

### 1. Đầu file và đường dẫn

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
```

- Dùng `jakarta.tags.core` / `jakarta.tags.fmt`, **không** dùng `http://java.sun.com/jsp/jstl/...` của bản cũ.
- Mọi link, `action` của form, `src` ảnh, file css/js đều bắt đầu bằng `${ctx}`: `href="${ctx}/products/${p.id}"`, `<link rel="stylesheet" href="${ctx}/css/shop.css">`.
- Ảnh lấy từ DB (sản phẩm, avatar, ảnh trả hàng) đã có dạng `/images/...`, chỉ cần ghép `${ctx}` vào trước: `src="${ctx}${p.imageUrl}"`.
- Tên file JSP phân biệt chữ hoa/thường và không được có dấu cách thừa.

### 2. Không đổi các tên sau

- **Tên biến model** (`${products}`, `${order}`, `${filter}`...) và tên thuộc tính của chúng (`${p.name}`, `${order.status.label}`...). Muốn biết một biến có gì, xem class DTO cùng tên trong `src/main/java/com/isp392/petfood/dto/`.
- **`name` của input / select / textarea**, cả các input ẩn (`<input type="hidden">`).
- **`action`, `method` và `enctype` của form.** Nút đổi trạng thái (huỷ đơn, xoá, ẩn/hiện...) là form `POST` nhỏ. Có thể đổi giao diện nút, nhưng không được đổi nó thành link `<a>` (GET).
- **Tham số trên URL** của form lọc (GET): `keyword`, `categoryId`, `status`, `page`...

### 3. CSRF: form POST nào cũng phải có token

Spring Security từ chối mọi request POST không có token (lỗi 403). Có hai cách:

- Form viết bằng `<form:form ...>`: token tự được thêm vào.
- Form HTML thường (`<form method="post">`): phải có dòng này bên trong form:

  ```jsp
  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
  ```

Khi tạo form mới hoặc tách form ra thành nhiều form, nhớ thêm dòng trên. Nút "Đăng xuất" là `POST /logout` nên cũng cần token.

### 4. Form có kiểm tra lỗi (`<form:form>`)

Các form nhập liệu (đăng ký, hồ sơ, đặt hàng, sản phẩm, lô...) dùng thư viện form của Spring:

```jsp
<form:form method="post" action="${ctx}/register" modelAttribute="registerForm">
    <form:input path="email" type="email"/>
    <form:errors path="email" cssClass="err"/>   <%-- dòng lỗi dưới ô, do BE gửi lên --%>
</form:form>
```

- `modelAttribute` và `path` là tên field phía BE, không đổi. `form:input` tự điền lại giá trị cũ khi báo lỗi.
- Được thêm `class`, `placeholder`, `id`... cho đẹp (`cssClass="..."`, `cssErrorClass="..."` để tô đỏ ô lỗi), nhưng giữ `<form:errors>` để người dùng thấy lỗi.
- Form có upload file phải giữ `enctype="multipart/form-data"`: form sản phẩm, hồ sơ khách (avatar), yêu cầu trả hàng.

### 5. Hiện dữ liệu an toàn

- Chữ do người dùng nhập (tên, mô tả, đánh giá, địa chỉ...) phải in bằng `<c:out value="${...}"/>`, không in thẳng `${...}`, để tránh chèn mã HTML/JS (XSS).
- Tiền: `<fmt:formatNumber value="${p.price}" type="number"/> ₫`.
- Enum (trạng thái đơn, hạng thành viên, độ tuổi...) đều có `label` tiếng Việt, trừ `role` (`CUSTOMER` / `STAFF` / `ADMIN`): dùng `${order.status.label}` để hiện chữ, còn `${order.status}` (VD `PENDING`) dùng để so sánh hoặc làm tên class CSS.

### 6. Thông báo và phân trang (giống nhau trên mọi trang)

- **Thông báo**: sau khi lưu / bấm nút, BE gửi một trong ba biến `successMessage`, `warningMessage`, `errorMessage`. Hai file `common/_header.jspf` và `staff/_nav.jspf` đã hiện sẵn cả ba, chỉ cần làm style (VD toast, alert).
- **Phân trang** (trang danh sách): BE gửi `currentPage` (tính từ 1), `totalPages`, `totalItems` và `filterQuery` (bộ lọc đang chọn, đã mã hoá sẵn). Link sang trang khác phải giữ `filterQuery`:

  ```jsp
  <a href="${ctx}/products?page=${i}&${filterQuery}">${i}</a>
  ```

## Các file dùng chung

| File | Dùng ở | Nội dung |
|---|---|---|
| `common/_header.jspf` | Mọi trang phía khách (sản phẩm, giỏ, đơn, hồ sơ, hỗ trợ) | Thanh đầu trang: logo, Flash Sale, Hỗ trợ, đăng nhập / tên + avatar, `Giỏ hàng (${cartItemCount})`, Đăng xuất; khối thông báo |
| `staff/_head.jspf` | Mọi trang `/staff` và `/admin` | Phần `<head>` (meta + CSS tạm). FE thay bằng `<link>` tới file CSS riêng |
| `staff/_nav.jspf` | Mọi trang `/staff` và `/admin` | Menu quản lý (Admin thấy thêm Thống kê, Nhân viên), tên người dùng, Đăng xuất; khối thông báo |
| `common/_order-detail.jspf` | `customer/order-detail.jsp`, `staff/orders/detail.jsp` | Thân trang chi tiết đơn (dòng hàng, lô + HSD, các mốc trạng thái) |
| `common/_return-detail.jspf` | `customer/return-detail.jsp`, `staff/returns/detail.jsp` | Thân trang chi tiết yêu cầu trả hàng |
| `support/_action-link.jspf` | `support/chat.jsp` | Link "Đi tới trang liên quan" của một bước chatbox |

Các file `.jspf` được include tĩnh (`<%@ include file="..." %>`): trang include phải khai báo taglib và biến `ctx` trước dòng include. Sửa giao diện chung (menu, header) thì sửa ở các file này, không chép ra từng trang.

Biến có ở **mọi trang**:

- `currentUser`: người đang đăng nhập (`null` nếu là khách vãng lai). Có `fullName`, `email`, `role` (`CUSTOMER` / `STAFF` / `ADMIN`), `avatarUrl`.
- `cartItemCount`: số dòng trong giỏ (chỉ có khi là khách hàng đã đăng nhập).

## Bản đồ trang

Cột "Biến chính" là các biến model quan trọng của trang. Danh sách đầy đủ có trong JSP hiện tại và ở controller tương ứng (`src/main/java/com/isp392/petfood/controller/`).

### Không cần đăng nhập

| URL | File JSP | Biến chính / ghi chú |
|---|---|---|
| `/`, `/products` | `product/list.jsp` | `products`, `filter`, `categories`, `brands`, `speciesList`, `ageGroups`, phân trang. Form lọc GET: `keyword`, `categoryId`, `species`, `ageGroup`, `brand`, `minPrice`, `maxPrice` |
| `/products/{id}` | `product/detail.jsp` | `product` (5 ảnh, tồn, HSD lô gần nhất), `reviewSummary`, `flashSaleOffers`. Nút thêm giỏ: `POST /cart/add` với `productId`, `quantity` |
| `/flash-sale` | `product/flash-sale.jsp` | `offers`. Thêm giỏ: `POST /cart/add` với `flashSaleItemId`, `quantity` |
| `/login` | `auth/login.jsp` | Form `POST /login` với `email`, `password` (+ CSRF). `googleLoginEnabled`. Thông báo theo URL: `?error`, `?locked`, `?expired`, `?logout`, `?reset`, `?registered`, `?googleError` |
| `/register` | `auth/register.jsp` | `registerForm`: `fullName`, `email`, `phone`, `password`, `confirmPassword` |
| `/forgot-password` | `auth/forgot-password.jsp` | `forgotPasswordForm`: `email` |
| `/forgot-password/verify` | `auth/reset-password.jsp` | `otpResetForm`: `otp`, `newPassword`, `confirmPassword`. `email`, `otpMinutes`, `maxAttempts`, `resendSeconds`. Gửi lại mã: `POST /forgot-password/resend` |
| `/support?node={id}` | `support/chat.jsp` | `chat` (các bước đã chọn + lựa chọn tiếp theo) |
| `/support/ticket?node={id}` | `support/ticket-form.jsp` | `supportTicketForm`: `nodeId`, `contactName`, `contactEmail`, `content`. `nodeLabel` |
| (mọi lỗi 400/403/404/500) | `error/error.jsp` | `status`, `errorTitle`, `errorDetail`. Trang này không include header |

### Khách hàng (CUSTOMER)

| URL | File JSP | Biến chính / ghi chú |
|---|---|---|
| `/cart` | `customer/cart.jsp` | `cart`. Đổi số lượng: `POST /cart/items/{id}/quantity` (`quantity`); xoá: `POST /cart/items/{id}/delete` |
| `/checkout` | `customer/checkout.jsp` | `checkoutForm`: `shippingAddress`, `paymentMethod`. `summary`, `paymentMethods`, `vnpayEnabled`. Nút tính phí ship: `POST /checkout/quote`; đặt hàng: `POST /checkout` |
| `/orders` | `customer/orders.jsp` | `orders`, phân trang |
| `/orders/{id}` | `customer/order-detail.jsp` | `order`, `returns`, `canRequestReturn`. Huỷ: `POST /orders/{id}/cancel` (`cancelReason`); trả tiền VNPay tiếp: `POST /orders/{id}/pay` |
| `/orders/{id}/returns/new` | `customer/return-form.jsp` | `returnForm`: `reason`, `description`, `lines[i].orderItemId/selected/quantity/opened`, `media` (1–5 file), `refundBankName`, `refundAccountNo`, `refundAccountHolder`. `returnableLines`, `reasons`, `cod`, `orderId` |
| `/orders/{id}/returns/{returnId}` | `customer/return-detail.jsp` | `ret` |
| `/orders/{id}/items/{itemId}/review` | `customer/review-form.jsp` | `reviewForm`: `rating`, `title`, `content`. `productName`, `orderId`, `itemId` |
| `/profile` | `customer/profile.jsp` | `profileForm`: `fullName`, `phone`, `avatar` (file), `removeAvatar`. `profile` (email, hạng thành viên, chi tiêu...) |

### Nhân viên (STAFF và ADMIN)

| URL | File JSP | Biến chính / ghi chú |
|---|---|---|
| `/staff` | `staff/dashboard.jsp` | `pageTitle`, `alertSummary` |
| `/staff/categories` | `staff/categories/list.jsp` | `categories`. Nút: `POST .../{id}/toggle-status`, `.../{id}/delete` |
| `/staff/categories/new`, `/{id}/edit` | `staff/categories/form.jsp` | `categoryForm`: `name`, `petType`, `status`. `categoryId` (null = thêm mới), `petTypes`, `categoryStatuses` |
| `/staff/products` | `staff/products/list.jsp` | `products`, `categories`, `speciesList`, `productStatuses`, phân trang. Lọc: `keyword`, `categoryId`, `species`, `status` |
| `/staff/products/{id}` | `staff/products/detail.jsp` | `product`, `lots`. Nút: `toggle-status`, `delete` |
| `/staff/products/new`, `/{id}/edit` | `staff/products/form.jsp` | `productForm`: `sku`, `barcode`, `name`, `brand`, `description`, `categoryId`, `species`, `ageGroup`, `sellingPrice`, `lowStockThreshold`, `status`, `image1`…`image5` (file), `firstLotExpiryDate`, `firstLotQty`. Form multipart |
| `/staff/lots` | `staff/lots/list.jsp` | `lots`, `lotViews`, `products`, phân trang. Lọc: `view`, `productId`, `keyword` |
| `/staff/lots/new`, `/{id}/edit` | `staff/lots/form.jsp` | `lotForm`: `productId`, `expiryDate`, `receivedQty`. `lotId`, `products` / `lot` |
| `/staff/alerts` | `staff/alerts.jsp` | `lowStockProducts`, `nearExpiryLots` |
| `/staff/orders` | `staff/orders/list.jsp` | `orders`, `statuses`, `cancelRequestCount`, phân trang. Lọc: `status`, `cancelRequested`, `keyword` |
| `/staff/orders/{id}` | `staff/orders/detail.jsp` | `order`. Nút `POST /staff/orders/{id}/...`: `confirm`, `pack`, `ship`, `complete`, `returned`, `cancel` (`cancelReason`), `cancel-request/approve`, `cancel-request/reject`, `refunded` |
| `/staff/returns` | `staff/returns/list.jsp` | `returns`, `statuses`, phân trang |
| `/staff/returns/{id}` | `staff/returns/detail.jsp` | `ret`, `inspectForm` (`lines[i].returnItemId/result/note/refund`), `inspectionResults`. Nút: `approve`, `reject` (`rejectReason`), `receive`, `inspect`, `refunded` |
| `/staff/flash-sales` | `staff/flash-sales/list.jsp` | `sales` |
| `/staff/flash-sales/new`, `/{id}/edit` | `staff/flash-sales/form.jsp` | `flashSaleForm`: `name`, `startTime`, `endTime`. `saleId` |
| `/staff/flash-sales/{id}` | `staff/flash-sales/detail.jsp` | `sale`, `items`, `redLots`, `itemForm` (`lotId`, `salePrice`, `allocatedQty`). Nút: `activate`, `pause`, `resume`, `end`, `delete`, `items/{itemId}/delete` |
| `/staff/reviews` | `staff/reviews/list.jsp` | `reviews`, `statuses`, phân trang. Nút: `POST .../{id}/reply` (`content`), `hide`, `show`, đều kèm `back` (giữ bộ lọc) |
| `/staff/support` | `staff/support/list.jsp` | `tickets`, `statuses`, phân trang |
| `/staff/support/{id}` | `staff/support/detail.jsp` | `ticket`, `replyDraft`. Nút: `claim`, `reply` (`content`), `close`, `spam`, `replies/{replyId}/resend` |
| `/staff/chat-nodes` | `staff/chat-nodes/list.jsp` | `nodes` (cây kịch bản). Nút: `hide`, `show`, `delete` |
| `/staff/chat-nodes/new?parent={id}`, `/{id}/edit` | `staff/chat-nodes/form.jsp` | `chatNodeForm`: `parentId`, `label`, `botMessage`, `actionUrl`, `sortOrder`, `status`. `nodeId`, `parentOptions`, `nodeStatuses` |

### Chỉ ADMIN

| URL | File JSP | Biến chính / ghi chú |
|---|---|---|
| `/admin?from=&to=` | `admin/dashboard.jsp` | `stats`, `alertSummary`, `filterFrom`, `filterTo` (ngày dạng `yyyy-MM-dd`) |
| `/admin/employees` | `admin/employees/list.jsp` | `employees`, `roles`, `statuses`, phân trang. Nút `lock` / `unlock` kèm `back` |
| `/admin/employees/new` | `admin/employees/create.jsp` | `employeeCreateForm`: `fullName`, `email`, `phone`, `role`, `password`, `confirmPassword` |
| `/admin/employees/{id}/edit` | `admin/employees/edit.jsp` | `employee`, `employeeEditForm` (`fullName`, `phone`, `role`), `passwordResetForm` (`newPassword`, `confirmPassword`, gửi tới `POST .../{id}/password`) |
| (nút ở `/staff/orders` và `/admin`) | | `POST /admin/membership/recalculate`: tính lại hạng thành viên ngay. Nút này chỉ hiện với Admin |

## Khi gặp lỗi

| Hiện tượng | Nguyên nhân thường gặp |
|---|---|
| Bấm nút ra trang 403 | Form POST thiếu token CSRF, hoặc tài khoản không đúng vai trò |
| Bấm lưu nhưng dữ liệu không đổi / ô bị trống | Đổi `name` / `path` của input, hoặc input nằm ngoài thẻ `<form>` |
| Trang trắng hoặc lỗi 500 sau khi sửa JSP | Gõ sai cú pháp JSP/EL (thiếu `}`, thẻ `c:` không đóng); xem lỗi chi tiết trong console |
| Ảnh sản phẩm không hiện | Thiếu `${ctx}` trước URL ảnh |
| CSS mới không có tác dụng | Chưa build lại sau khi sửa file trong `static/`, hoặc trình duyệt còn cache (Ctrl+F5) |
| App không khởi động, báo `Schema-validation` | DB cũ, chạy lại `FoodPetShop_FullSetup.sql` mới nhất |
| App không khởi động, báo lỗi đăng nhập SQL Server | Sai `DB_PASSWORD` trong `.env`, hoặc chạy app sai thư mục làm việc |
