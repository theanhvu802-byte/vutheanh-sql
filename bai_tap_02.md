Họ tên : Vũ Thế Anh

MSSV : K235480106004

Lớp : K59KMT.K01


SAU ĐÂY EM XIN PHÉP TRÌNH BÀY

# PHẦN 1 : Thiết kế và Khởi tạo Cấu trúc Dữ liệu

  Chủ đề quản lí : Quản lí kết quả học tập

 <img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-23 012814" src="https://github.com/user-attachments/assets/70ca71bb-ef52-441b-934f-3a9a9a04dbd7" />

 
  + Ảnh trên em tạo 1 database mang tên quanliketquahoctap cùng vơi mã sinh viên của em 
  

  <img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-23 013736" src="https://github.com/user-attachments/assets/bf061a97-7f51-4732-a8ef-a7aba61f6ea8" />
  
  + Ảnh này em tạo 3 bảng theo yêu cầu của đề bài : Sử dụng đa dạng các kiểu dữ liệu , Áp dụng đúng quy tắc đặt tên (BướuLạcĐà) , Sử dụng cặp ngoặc [ ] để bọc tên bảng và tên trường trong script khởi tạo , Có giải thích chỗ nào là PK, chỗ nào là FK, trường nào có ràng buộc cứng CK

# PHẦN 2 : Xây dựng Function

Câu 1: Các loại hàm build-in (có sẵn) trong SQL Server

Trong SQL Server, các hàm có sẵn được chia thành nhiều nhóm mục đích khác nhau. Dưới đây là những hàm tiêu biểu mà em đã tìm hiểu:

Hàm toán học: ROUND() (dùng để làm tròn điểm số của sinh viên đến 1 hoặc 2 chữ số thập phân).

Khai thác: SELECT ROUND(8.745, 1); -> Kết quả: 8.7

Hàm chuỗi: LEN() (dùng để đếm độ dài của họ tên sinh viên để kiểm tra tính hợp lệ).

Khai thác: SELECT LEN(N'Thế Anh'); -> Kết quả: 7

Hàm ngày tháng: GETDATE() (dùng để ghi lại thời gian chính xác khi nhập điểm vào hệ thống).

Khai thác: SELECT GETDATE();

Hàm hệ thống: DB_NAME() (dùng để lấy tên Database hiện tại đang làm việc).

Khai thác: SELECT DB_NAME();

Câu 2: Mục đích và phân loại hàm tự viết (User-Defined Functions - UDF)

Mục đích: Hàm tự viết dùng để đóng gói các logic tính toán phức tạp mang tính đặc thù của dự án (ví dụ: cách tính điểm ưu tiên của trường TNUT) giúp code ngắn gọn và có thể tái sử dụng nhiều lần.

Tại sao cần tự viết: Mặc dù hệ thống có nhiều hàm build-in nhưng chúng chỉ giải quyết các bài toán chung chung. Khi cần xử lý logic nghiệp vụ riêng (Business Logic) thì phải tự viết.

Phân loại:

Scalar Function (Hàm vô hướng): Luôn trả về đúng một giá trị duy nhất (như một con số hoặc một chuỗi). Thường dùng để tính toán đơn giản.

Inline Table-Valued Function (Hàm trả về bảng đơn giản): Trả về một bảng dữ liệu từ một câu lệnh SELECT duy nhất. Hiệu năng rất cao.

Multi-statement Table-Valued Function (Hàm trả về bảng phức tạp): Trả về một bảng dữ liệu nhưng bên trong có cấu trúc phức tạp, sử dụng nhiều câu lệnh và biến bảng để xử lý dữ liệu trước khi trả về.

Logic bài toán: "Trong hệ thống quản lý đào tạo, việc theo dõi tiến độ học tập của sinh viên là rất quan trọng. Nhà trường cần biết mỗi sinh viên đã tích lũy được bao nhiêu tín chỉ để xét điều kiện học tiếp hoặc xét tốt nghiệp."

Lý do cần Function:
"Vì việc tính tổng tín chỉ phải thực hiện liên tục cho hàng nghìn sinh viên và trên nhiều báo cáo khác nhau, nên em xây dựng Function này để tối ưu hóa việc tái sử dụng code. Thay vì viết lại câu lệnh tính toán ở khắp mọi nơi, em chỉ cần gọi hàm này ra là có ngay kết quả chính xác."

<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-23 022133" src="https://github.com/user-attachments/assets/1cc2592c-9089-4743-93c0-a292e0768c1d" />

 - Ảnh trên em đã khai thác hàm sql 

Yêu cầu: Xây dựng một hàm để nhà trường có thể nhanh chóng truy xuất Danh sách các môn học mà một sinh viên cụ thể đã tham gia thi, kèm theo số tín chỉ và điểm số tương ứng của môn đó.

Lý do cần hàm này: Thay vì mỗi lần xem điểm của một sinh viên phải viết lệnh JOIN phức tạp giữa bảng Môn học và bảng Điểm, em đóng gói nó vào một hàm. Chỉ cần truyền Mã sinh viên vào là có ngay bảng điểm chi tiết của người đó

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/7bfbcb7a-da1e-4734-a661-4f83c1d1b117" />

 - Ảnh trên em đã khai thác hàm sql

Yêu cầu: Xây dựng một hàm thống kê chi tiết kết quả học tập của tất cả sinh viên. Hàm này không chỉ lấy ra điểm số mà còn phải tự động tính toán để xếp loại học lực và đưa ra trạng thái 'Đạt' hoặc 'Học lại' cho từng môn học.

Lý do cần hàm này: Vì logic xếp loại và đánh giá trạng thái (ví dụ: dưới 4.0 là học lại) là các quy tắc nghiệp vụ riêng của nhà trường. Việc sử dụng Multi-statement Function giúp em có thể xử lý từng dòng dữ liệu, áp dụng các điều kiện IF/CASE phức tạp trước khi trả về một bảng báo cáo hoàn chỉnh cho giáo viên

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/266d47a4-7e7d-440f-bc20-c28015080c37" />

- Ảnh trên em đã khai thác hàm sql

# PHẦN 3 : Xây dựng Store Procedure

System Store Procedure là các thủ tục được lưu trữ sẵn trong Database hệ thống (thường bắt đầu bằng tiền tố sp_). Chúng giúp quản trị viên thực hiện các tác vụ quản lý và truy xuất thông tin hệ thống một cách nhanh chóng.

Dưới đây là một số System SP tiêu biểu mà em đã tìm hiểu:

  sp_help: * Cách dùng: EXEC sp_help '[TenBang]';

Giải thích: Đây là lệnh cực kỳ phổ biến để xem cấu trúc chi tiết của một bảng (kiểu dữ liệu, khóa chính, khóa ngoại). Chính em đã dùng lệnh này ở Phần 1 để kiểm tra bảng.

  sp_rename: * Cách dùng: EXEC sp_rename 'TenCu', 'TenMoi';

Giải thích: Dùng để đổi tên các đối tượng trong cơ sở dữ liệu như bảng, cột mà không cần phải xóa đi tạo lại.

  sp_helpdb: * Cách dùng: EXEC sp_helpdb;

Giải thích: Cung cấp thông tin tổng quan về tất cả các Database đang có trên Server (kích thước, trạng thái, đường dẫn file lưu trữ).

  sp_who: * Cách dùng: EXEC sp_who;

Giải thích: Cho biết danh sách các người dùng và tiến trình (process) đang kết nối vào SQL Server, giúp kiểm soát tài nguyên hệ thống.

 * Yêu cầu: Viết một Store Procedure để nhập điểm cho sinh viên.

Logic kiểm tra: 1. Kiểm tra xem điểm nhập vào có nằm trong khoảng từ 0 đến 10 không. Nếu không, thông báo lỗi và thoát.
2. Nếu sinh viên và môn học đó đã tồn tại trong bảng điểm, thủ tục sẽ tiến hành Cập nhật (UPDATE) điểm mới.
3. Nếu chưa tồn tại, thủ tục sẽ tiến hành Thêm mới (INSERT) bản ghi điểm đó

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/c178b8ad-51ce-4678-9720-829341dcc6db" />
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/95fad98e-556e-4fc4-903d-e57a4e359789" />

- Em đã khai thác thành công 1 Store Procedure

 - Yêu cầu: Xây dựng một Store Procedure để Tính điểm trung bình tích lũy của một sinh viên và trả giá trị đó về thông qua tham số OUTPUT.

Lý do cần dùng OUTPUT: Trong các hệ thống lớn, sau khi tính được điểm trung bình, kết quả này thường được dùng ngay để thực hiện các logic tiếp theo như: xét học bổng, xét cảnh báo học vụ hoặc phân loại sinh viên. Việc dùng OUTPUT giúp lập trình viên lấy được giá trị đó ra một cách trực tiếp và nhanh chóng

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/171351ea-cb10-4c92-9d84-3a81942695d9" />

 - Ảnh trên em đã khai thác thành công 1 Store Procedure


- Yêu cầu: Xây dựng một Store Procedure để xuất ra Báo cáo kết quả học tập chi tiết của sinh viên.

Lý do cần dùng Result set với JOIN: Trong thực tế, dữ liệu nằm rời rạc ở nhiều bảng: thông tin sinh viên ở bảng [DanhSachSinhVien], tên môn học ở bảng [DanhSachMonHoc], và điểm số ở bảng [KetQuaHocTap]. Để có một báo cáo có nghĩa, em cần thực hiện JOIN 3 bảng này lại với nhau. Việc đưa lệnh này vào Store Procedure giúp hệ thống chỉ cần gọi một câu lệnh đơn giản là có ngay báo cáo tổng hợp mà không cần viết lại đoạn mã phức tạp

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/90178eaa-b130-4bf6-9c9b-088ce25f6506" />

- Ảnh trên em đã khai thác thành công 1 Store Procedure

# PHẦN 4 : Trigger và Xử lý logic nghiệp vụ

Yêu cầu: Viết một Trigger để khi chúng ta cập nhật mã sinh viên hoặc thông tin cá nhân ở bảng [DanhSachSinhVien] (Bảng A), hệ thống sẽ tự động ghi nhận hoặc kiểm tra tính đồng bộ dữ liệu ở các bảng liên quan (Bảng B)..

Kịch bản thực tế: Giả sử nhà trường có một bảng phụ là [LogThayDoiEmail] để theo dõi lịch sử đổi email của sinh viên. Mỗi khi sinh viên cập nhật email mới ở bảng chính, Trigger sẽ tự động chèn một bản ghi vào bảng phụ này để lưu lại dấu vết (Audit Log). Điều này giúp quản trị viên biết được ai đã đổi email vào lúc nào





  


  
