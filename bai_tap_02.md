Họ tên : Vũ Thế Anh

MSSV : K235480106004

Lớp : K59KMT.K01


SAU ĐÂY EM XIN PHÉP TRÌNH BÀY

# PHẦN 1 : Thiết kế và Khởi tạo Cấu trúc Dữ liệu

-- 1. Tạo Database (Đúng tên: [TenDuAn]_[MaSV])
CREATE DATABASE [QuanLyKetQuaHocTap_K235480106004];
GO

USE [QuanLyKetQuaHocTap_K235480106004];
GO

-- 2. Tạo bảng [DanhSachSinhVien] (Sử dụng BướuLạcĐà và ngoặc [])
CREATE TABLE [DanhSachSinhVien] (
    [MaSinhVien] NVARCHAR(20) PRIMARY KEY, -- PK: Khóa chính
    [HoTen] NVARCHAR(100) NOT NULL,
    [EmailCuaSV] NVARCHAR(100),
    [NgaySinh] DATETIME
);

-- 3. Tạo bảng [DanhSachMonHoc]
CREATE TABLE [DanhSachMonHoc] (
    [MaMonHoc] NVARCHAR(10) PRIMARY KEY, -- PK
    [TenMonHoc] NVARCHAR(100),
    [SoTinChi] INT CONSTRAINT CK_TinChi CHECK ([SoTinChi] > 0) -- CK: Ràng buộc số tín chỉ > 0
);

-- 4. Tạo bảng [KetQuaHocTap]
CREATE TABLE [KetQuaHocTap] (
    [MaSinhVien] NVARCHAR(20), -- FK
    [MaMonHoc] NVARCHAR(10),  -- FK
    [DiemSo] FLOAT CONSTRAINT CK_Diem CHECK ([DiemSo] BETWEEN 0 AND 10), -- CK: Điểm từ 0..10
    [HocKy] INT,
    CONSTRAINT PK_KetQua PRIMARY KEY ([MaSinhVien], [MaMonHoc]), -- Khóa chính kết hợp
    CONSTRAINT FK_SinhVien FOREIGN KEY ([MaSinhVien]) REFERENCES [DanhSachSinhVien]([MaSinhVien]),
    CONSTRAINT FK_MonHoc FOREIGN KEY ([MaMonHoc]) REFERENCES [DanhSachMonHoc]([MaMonHoc])
);

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

GO
CREATE FUNCTION [fn_DanhSachMonDaHoc] (@MaSV NVARCHAR(20))
RETURNS TABLE
AS
RETURN (
    SELECT 
        mh.[TenMonHoc], 
        mh.[SoTinChi], 
        kq.[DiemSo]
    FROM [KetQuaHocTap] kq
    JOIN [DanhSachMonHoc] mh ON kq.[MaMonHoc] = mh.[MaMonHoc]
    WHERE kq.[MaSinhVien] = @MaSV
);
GO
-- Xem danh sách các môn mà Thế Anh đã học và điểm số tương ứng
SELECT * FROM [dbo].[fn_DanhSachMonDaHoc]('K235480106004');

<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-23 022133" src="https://github.com/user-attachments/assets/1cc2592c-9089-4743-93c0-a292e0768c1d" />

 - Ảnh trên em đã khai thác hàm sql 

Yêu cầu: Xây dựng một hàm để nhà trường có thể nhanh chóng truy xuất Danh sách các môn học mà một sinh viên cụ thể đã tham gia thi, kèm theo số tín chỉ và điểm số tương ứng của môn đó.

Lý do cần hàm này: Thay vì mỗi lần xem điểm của một sinh viên phải viết lệnh JOIN phức tạp giữa bảng Môn học và bảng Điểm, em đóng gói nó vào một hàm. Chỉ cần truyền Mã sinh viên vào là có ngay bảng điểm chi tiết của người đó

USE [QuanLyKetQuaHocTap_K235480106004];
GO

CREATE FUNCTION [fn_DanhSachDiemChiTiet] (@MaSV NVARCHAR(20))
RETURNS TABLE
AS
RETURN (
    SELECT 
        mh.[MaMonHoc],
        mh.[TenMonHoc], 
        mh.[SoTinChi], 
        kq.[DiemSo]
    FROM [KetQuaHocTap] kq
    JOIN [DanhSachMonHoc] mh ON kq.[MaMonHoc] = mh.[MaMonHoc]
    WHERE kq.[MaSinhVien] = @MaSV
);
GO
-- Xem bảng điểm chi tiết của sinh viên Thế Anh (K235480106004)
SELECT * FROM [dbo].[fn_DanhSachDiemChiTiet]('K235480106004');

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/7bfbcb7a-da1e-4734-a661-4f83c1d1b117" />

 - Ảnh trên em đã khai thác hàm sql

Yêu cầu: Xây dựng một hàm thống kê chi tiết kết quả học tập của tất cả sinh viên. Hàm này không chỉ lấy ra điểm số mà còn phải tự động tính toán để xếp loại học lực và đưa ra trạng thái 'Đạt' hoặc 'Học lại' cho từng môn học.

Lý do cần hàm này: Vì logic xếp loại và đánh giá trạng thái (ví dụ: dưới 4.0 là học lại) là các quy tắc nghiệp vụ riêng của nhà trường. Việc sử dụng Multi-statement Function giúp em có thể xử lý từng dòng dữ liệu, áp dụng các điều kiện IF/CASE phức tạp trước khi trả về một bảng báo cáo hoàn chỉnh cho giáo viên

USE [QuanLyKetQuaHocTap_K235480106004];
GO

CREATE FUNCTION [fn_ThongKeXepLoaiChiTiet]()
RETURNS @BangKetQua TABLE (
    [MaSV] NVARCHAR(20),
    [TenMon] NVARCHAR(100),
    [Diem] FLOAT,
    [XepLoai] NVARCHAR(20),
    [TrangThai] NVARCHAR(20)
)
AS
BEGIN
    -- Chèn dữ liệu và xử lý logic phức tạp vào biến bảng @BangKetQua
    INSERT INTO @BangKetQua
    SELECT 
        kq.[MaSinhVien],
        mh.[TenMonHoc],
        kq.[DiemSo],
        -- Logic xếp loại
        CASE 
            WHEN kq.[DiemSo] >= 8.5 THEN N'Giỏi'
            WHEN kq.[DiemSo] >= 7.0 THEN N'Khá'
            WHEN kq.[DiemSo] >= 4.0 THEN N'Trung bình'
            ELSE N'Yếu'
        END,
        -- Logic đánh giá đạt hay không
        CASE 
            WHEN kq.[DiemSo] >= 4.0 THEN N'Đạt'
            ELSE N'Học lại'
        END
    FROM [KetQuaHocTap] kq
    JOIN [DanhSachMonHoc] mh ON kq.[MaMonHoc] = mh.[MaMonHoc];

    RETURN;
END;
GO
-- Xem báo cáo thống kê xếp loại của toàn bộ sinh viên
SELECT * FROM [dbo].[fn_ThongKeXepLoaiChiTiet]();

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

USE [QuanLyKetQuaHocTap_K235480106004];
GO

CREATE PROCEDURE [sp_NhapDiemSinhVien]
    @MaSV NVARCHAR(20),
    @MaMon NVARCHAR(10),
    @Diem FLOAT,
    @HocKy INT
AS
BEGIN
    -- 1. Kiểm tra điều kiện logic: Điểm phải từ 0 đến 10
    IF (@Diem < 0 OR @Diem > 10)
    BEGIN
        PRINT N'Lỗi: Điểm số phải nằm trong khoảng từ 0 đến 10!';
        RETURN;
    END

    -- 2. Kiểm tra xem đã có bản ghi này chưa
    IF EXISTS (SELECT 1 FROM [KetQuaHocTap] WHERE [MaSinhVien] = @MaSV AND [MaMonHoc] = @MaMon)
    BEGIN
        -- Nếu đã có thì cập nhật điểm mới
        UPDATE [KetQuaHocTap]
        SET [DiemSo] = @Diem, [HocKy] = @HocKy
        WHERE [MaSinhVien] = @MaSV AND [MaMonHoc] = @MaMon;
        PRINT N'Thông báo: Đã cập nhật điểm thành công cho SV ' + @MaSV;
    END
    ELSE
    BEGIN
        -- Nếu chưa có thì thêm mới
        INSERT INTO [KetQuaHocTap] ([MaSinhVien], [MaMonHoc], [DiemSo], [HocKy])
        VALUES (@MaSV, @MaMon, @Diem, @HocKy);
        PRINT N'Thông báo: Đã thêm mới điểm thành công cho SV ' + @MaSV;
    END
END;
GO
-- Trường hợp 1: Thêm mới điểm cho Thế Anh ở môn C# (CS01)
EXEC [sp_NhapDiemSinhVien] 'K235480106004', 'CS01', 9.0, 1;

-- Trường hợp 2: Cập nhật lại điểm môn SQL01 cho Thế Anh thành 10 điểm
EXEC [sp_NhapDiemSinhVien] 'K235480106004', 'SQL01', 10.0, 1;

-- Trường hợp 3: Kiểm tra logic lỗi (Nhập 15 điểm)
EXEC [sp_NhapDiemSinhVien] 'K235480106004', 'SQL01', 15.0, 1;

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/c178b8ad-51ce-4678-9720-829341dcc6db" />
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/95fad98e-556e-4fc4-903d-e57a4e359789" />

- Em đã khai thác thành công 1 Store Procedure

 - Yêu cầu: Xây dựng một Store Procedure để Tính điểm trung bình tích lũy của một sinh viên và trả giá trị đó về thông qua tham số OUTPUT.

Lý do cần dùng OUTPUT: Trong các hệ thống lớn, sau khi tính được điểm trung bình, kết quả này thường được dùng ngay để thực hiện các logic tiếp theo như: xét học bổng, xét cảnh báo học vụ hoặc phân loại sinh viên. Việc dùng OUTPUT giúp lập trình viên lấy được giá trị đó ra một cách trực tiếp và nhanh chóng

USE [QuanLyKetQuaHocTap_K235480106004];
GO

CREATE PROCEDURE [sp_BaoCaoHocTapToanDien]
AS
BEGIN
    SELECT 
        sv.[MaSinhVien],
        sv.[HoTen],
        mh.[TenMonHoc],
        mh.[SoTinChi],
        kq.[DiemSo],
        kq.[HocKy]
    FROM [DanhSachSinhVien] sv
    INNER JOIN [KetQuaHocTap] kq ON sv.[MaSinhVien] = kq.[MaSinhVien]
    INNER JOIN [DanhSachMonHoc] mh ON kq.[MaMonHoc] = mh.[MaMonHoc]
    ORDER BY sv.[MaSinhVien] ASC, kq.[HocKy] DESC;
END;
GO
-- Gọi thủ tục để xem báo cáo tổng hợp
EXEC [sp_BaoCaoHocTapToanDien];

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/171351ea-cb10-4c92-9d84-3a81942695d9" />

 - Ảnh trên em đã khai thác thành công 1 Store Procedure


- Yêu cầu: Xây dựng một Store Procedure để xuất ra Báo cáo kết quả học tập chi tiết của sinh viên.

Lý do cần dùng Result set với JOIN: Trong thực tế, dữ liệu nằm rời rạc ở nhiều bảng: thông tin sinh viên ở bảng [DanhSachSinhVien], tên môn học ở bảng [DanhSachMonHoc], và điểm số ở bảng [KetQuaHocTap]. Để có một báo cáo có nghĩa, em cần thực hiện JOIN 3 bảng này lại với nhau. Việc đưa lệnh này vào Store Procedure giúp hệ thống chỉ cần gọi một câu lệnh đơn giản là có ngay báo cáo tổng hợp mà không cần viết lại đoạn mã phức tạp

USE [QuanLyKetQuaHocTap_K235480106004];
GO

CREATE PROCEDURE [sp_BaoCaoKetQuaChiTiet]
AS
BEGIN
    -- Lệnh SELECT thực hiện JOIN 3 bảng để lấy thông tin tổng hợp
    SELECT 
        sv.[MaSinhVien],
        sv.[HoTen],
        mh.[TenMonHoc],
        mh.[SoTinChi],
        kq.[DiemSo],
        kq.[HocKy]
    FROM [DanhSachSinhVien] sv
    INNER JOIN [KetQuaHocTap] kq ON sv.[MaSinhVien] = kq.[MaSinhVien]
    INNER JOIN [DanhSachMonHoc] mh ON kq.[MaMonHoc] = mh.[MaMonHoc]
    ORDER BY sv.[MaSinhVien] ASC, kq.[HocKy] DESC;
END;
GO
-- Gọi thủ tục để xem toàn bộ báo cáo học tập
EXEC [sp_BaoCaoKetQuaChiTiet];

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/90178eaa-b130-4bf6-9c9b-088ce25f6506" />

- Ảnh trên em đã khai thác thành công 1 Store Procedure

# PHẦN 4 : Trigger và Xử lý logic nghiệp vụ

* Yêu cầu: Viết một Trigger để khi chúng ta cập nhật mã sinh viên hoặc thông tin cá nhân ở bảng [DanhSachSinhVien] (Bảng A), hệ thống sẽ tự động ghi nhận hoặc kiểm tra tính đồng bộ dữ liệu ở các bảng liên quan (Bảng B)..

Kịch bản thực tế: Giả sử nhà trường có một bảng phụ là [LogThayDoiEmail] để theo dõi lịch sử đổi email của sinh viên. Mỗi khi sinh viên cập nhật email mới ở bảng chính, Trigger sẽ tự động chèn một bản ghi vào bảng phụ này để lưu lại dấu vết (Audit Log). Điều này giúp quản trị viên biết được ai đã đổi email vào lúc nào

USE [QuanLyKetQuaHocTap_K235480106004];
GO

CREATE TABLE [LogThayDoiEmail] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [MaSV] NVARCHAR(20),
    [EmailCu] NVARCHAR(100),
    [EmailMoi] NVARCHAR(100),
    [NgayThayDoi] DATETIME DEFAULT GETDATE()
);
GO
USE [QuanLyKetQuaHocTap_K235480106004];
GO

CREATE TRIGGER [trg_LuuLichSuDoiEmail]
ON [DanhSachSinhVien]
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra xem cột Email có bị thay đổi không
    IF UPDATE([EmailCuaSV])
    BEGIN
        INSERT INTO [LogThayDoiEmail] ([MaSV], [EmailCu], [EmailMoi])
        SELECT 
            d.[MaSinhVien], 
            d.[EmailCuaSV], -- Dữ liệu cũ (từ bảng deleted)
            i.[EmailCuaSV]  -- Dữ liệu mới (từ bảng inserted)
        FROM deleted d
        JOIN inserted i ON d.[MaSinhVien] = i.[MaSinhVien];
        
        PRINT N'Trigger thông báo: Đã lưu lại lịch sử thay đổi email vào bảng Log.';
    END
END;
GO
-- Cập nhật email mới cho Thế Anh để kích hoạt Trigger
UPDATE [DanhSachSinhVien]
SET [EmailCuaSV] = 'theanh_moi_2026@tnut.edu.vn'
WHERE [MaSinhVien] = 'K235480106004';

-- Kiểm tra bảng B xem Trigger đã tự động "làm việc" chưa
SELECT * FROM [LogThayDoiEmail];

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/c701fa57-e24d-4ca0-a478-0d21d04f83a9" />

Hoàn thành ! 

* Em xây dựng một kịch bản đồng bộ dữ liệu giữa bảng [KetQuaHocTap] (Bảng A) và một bảng sao lưu tên là [KetQuaHocTap_Backup] (Bảng B).

Khi chèn dữ liệu mới vào bảng A, Trigger 1 sẽ tự động chèn sang bảng B.

Khi bảng B có sự thay đổi, Trigger 2 sẽ cập nhật ngược lại bảng A để đảm bảo dữ liệu hai bên luôn khớp nhau.

Mục tiêu: Quan sát hiện tượng gì sẽ xảy ra khi hai Trigger gọi nhau liên tiếp

USE [QuanLyKetQuaHocTap_K235480106004];
GO
CREATE TABLE [KetQuaHocTap_Backup] (
    [MaSinhVien] NVARCHAR(20),
    [MaMonHoc] NVARCHAR(10),
    [DiemSo] FLOAT,
    [HocKy] INT
);
GO
CREATE TRIGGER [trg_A_to_B]
ON [KetQuaHocTap]
AFTER INSERT
AS
BEGIN
    INSERT INTO [KetQuaHocTap_Backup]
    SELECT * FROM inserted;
    PRINT N'--- Trigger A đang chèn dữ liệu sang B ---';
END;
GO
CREATE TRIGGER [trg_B_to_A]
ON [KetQuaHocTap_Backup]
AFTER INSERT, UPDATE
AS
BEGIN
    -- Khi B thay đổi, cập nhật lại điểm ở A
    UPDATE [KetQuaHocTap]
    SET [DiemSo] = i.[DiemSo]
    FROM [KetQuaHocTap] a
    JOIN inserted i ON a.[MaSinhVien] = i.[MaSinhVien] AND a.[MaMonHoc] = i.[MaMonHoc];
    
    PRINT N'--- Trigger B đang cập nhật ngược lại A ---';
END;
GO
INSERT INTO [KetQuaHocTap] ([MaSinhVien], [MaMonHoc], [DiemSo], [HocKy])
VALUES ('K235480106004', 'CS01', 8.0, 2);


<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/dac6aee4-382f-4d60-a22e-293ae4e1819d" />

- Hiện tượng: Đây là lỗi Vòng lặp vô hạn (Infinite Loop) hoặc Đệ quy (Recursion).

Nguyên nhân: Khi chèn vào A -> Trigger A kích hoạt -> Chèn vào B. Khi chèn vào B -> Trigger B kích hoạt -> Cập nhật lại A. Việc cập nhật A lại vô tình làm Trigger A hiểu là có sự thay đổi và tiếp tục gọi B.

Giới hạn: SQL Server có cơ chế bảo vệ, chỉ cho phép các hành động này lặp lại tối đa 32 lần. Khi vượt quá, hệ thống sẽ tự ngắt và báo lỗi Maximum nesting level exceeded để tránh treo máy chủ

Về kỹ thuật: Việc thiết kế các Trigger cập nhật chéo nhau trực tiếp (A gọi B, B gọi A) là cực kỳ nguy hiểm và dễ gây lỗi hệ thống.

Giải pháp: * Nên hạn chế dùng Trigger cho việc đồng bộ 2 chiều.

Nếu bắt buộc phải dùng, cần sử dụng hàm IF TRIGGER_NESTLEVEL() > 1 RETURN; để chặn không cho Trigger chạy đệ quy.

Nên ưu tiên sử dụng Store Procedure để xử lý dữ liệu ở một nơi duy nhất thay vì để các Trigger tự "nói chuyện" với nhau.

# PHẦN 5 : Cursor và Duyệt dữ liệu

- Yêu cầu: Sử dụng Cursor để duyệt qua danh sách điểm của toàn bộ sinh viên. Với mỗi sinh viên, hệ thống sẽ kiểm tra điểm số và in ra một lời nhắn cá nhân hóa dựa trên kết quả của họ.

Lý do cần dùng Cursor: Vì mỗi sinh viên có một kết quả khác nhau và cần một lời nhắn khác nhau (người thì khen ngợi, người thì nhắc nhở học lại). Việc dùng Cursor giúp em 'cầm tay' từng bản ghi để xử lý riêng biệt các dòng lệnh PRINT phức tạp mà một câu lệnh SELECT thông thường khó trình bày đẹp được

USE [QuanLyKetQuaHocTap_K235480106004];
GO

-- Khai báo các biến để chứa dữ liệu khi duyệt qua từng dòng
DECLARE @TenSV NVARCHAR(200);
DECLARE @TenMon NVARCHAR(100);
DECLARE @Diem FLOAT;

-- 1. Khai báo Cursor để lấy danh sách điểm
DECLARE cur_ThongBaoDiem CURSOR FOR 
    SELECT sv.[HoTen], mh.[TenMonHoc], kq.[DiemSo]
    FROM [DanhSachSinhVien] sv
    JOIN [KetQuaHocTap] kq ON sv.[MaSinhVien] = kq.[MaSinhVien]
    JOIN [DanhSachMonHoc] mh ON kq.[MaMonHoc] = mh.[MaMonHoc];

-- 2. Mở Cursor
OPEN cur_ThongBaoDiem;

-- 3. Lấy dòng dữ liệu đầu tiên
FETCH NEXT FROM cur_ThongBaoDiem INTO @TenSV, @TenMon, @Diem;

-- 4. Vòng lặp duyệt qua từng bản ghi
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT N'--- THÔNG BÁO HỌC TẬP ---';
    PRINT N'Chào bạn: ' + @TenSV;
    PRINT N'Môn học: ' + @TenMon + N' - Điểm: ' + CAST(@Diem AS NVARCHAR(5));
    
    -- Xử lý logic riêng cho từng bản ghi
    IF @Diem >= 8.5
        PRINT N'Nhận xét: Kết quả xuất sắc! Tiếp tục phát huy nhé.';
    ELSE IF @Diem >= 4.0
        PRINT N'Nhận xét: Bạn đã vượt qua môn học này.';
    ELSE
        PRINT N'Nhận xét: Kết quả chưa đạt. Bạn cần đăng ký học lại.';
        
    PRINT ''; -- Dòng trống để dễ nhìn

    -- Tiến tới dòng tiếp theo
    FETCH NEXT FROM cur_ThongBaoDiem INTO @TenSV, @TenMon, @Diem;
END

-- 5. Đóng và giải phóng Cursor
CLOSE cur_ThongBaoDiem;
DEALLOCATE cur_ThongBaoDiem;
GO

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/28aab973-aa36-4cb7-8173-4ee2a4690f06" />
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/b3187d2e-6ff8-4245-95f8-8785b55779bf" />

Em đã hoàn thành yêu cầu đề bài là Viết một đoạn script sử dụng CURSOR để duyệt qua danh sách của 1 câu lệnh SQL dạng SELECT

- So sánh tốc độ giữa có dùng cursor và không dùng cursor (nếu cùng kết quả) thì thời gian xử lý cái nào nhanh hơn, cần ảnh chụp màn hình minh chứng.

  USE [QuanLyKetQuaHocTap_K235480106004];
GO

-- Đoạn mã thay thế Cursor
SELECT 
    sv.[HoTen], 
    mh.[TenMonHoc], 
    kq.[DiemSo],
    N'Nhận xét: ' + 
    CASE 
        WHEN kq.[DiemSo] >= 8.5 THEN N'Kết quả xuất sắc! Tiếp tục phát huy nhé.'
        WHEN kq.[DiemSo] >= 4.0 THEN N'Bạn đã vượt qua môn học này.'
        ELSE N'Kết quả chưa đạt. Bạn cần đăng ký học lại.'
    END AS [LoiNhan]
FROM [DanhSachSinhVien] sv
JOIN [KetQuaHocTap] kq ON sv.[MaSinhVien] = kq.[MaSinhVien]
JOIN [DanhSachMonHoc] mh ON kq.[MaMonHoc] = mh.[MaMonHoc];
SET STATISTICS TIME ON;
GO

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/90984971-2180-4adb-8066-cae9f699f589" />
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/8fc4eba9-bb73-4c5c-82f1-247147beb4c5" />

- Kết quả thực nghiệm: Với số lượng bản ghi nhỏ, cả hai phương pháp đều cho thời gian phản hồi gần như bằng 0 (0ms).

Phân tích kỹ thuật: >   - Cursor: Xử lý theo kiểu "Row-by-row" (từng dòng một). Mỗi dòng dữ liệu đều tiêu tốn một lượng tài nguyên để mở con trỏ, lấy dữ liệu và đóng con trỏ. Khi dữ liệu lên đến hàng triệu dòng, Cursor sẽ gây nghẽn cổ chai và tốn CPU rất lớn.

Lệnh SELECT thuần: Xử lý theo kiểu "Set-based" (cả tập hợp). SQL Server sử dụng bộ tối ưu hóa truy vấn để quét dữ liệu một lần duy nhất, giúp tốc độ luôn nhanh nhất có thể.

Vậy nên luôn ưu tiên dùng lệnh SELECT thuần túy. Chỉ dùng Cursor khi gặp các bài toán cực kỳ đặc thù mà các câu lệnh tập hợp không thể giải quyết được.

* Thử nghĩ bài toán khác, mà chỉ CURSOR mới giải quyết được, còn SQL rất khó giải quyết đc

Bài toán: "Xây dựng kịch bản Bảo trì & Phân quyền hàng loạt"
Yêu cầu: Nhà trường muốn tạo ra 100 cái Database con cho 100 lớp học khác nhau, hoặc muốn BACKUP từng bảng một thành từng file riêng biệt, hoặc gán quyền truy cập cho tất cả các bảng có tên bắt đầu bằng chữ 'KetQua_'

DECLARE @TableName NVARCHAR(255);
DECLARE @Sql NVARCHAR(MAX);

-- 1. Cursor lấy danh sách tất cả các bảng trong Database của Thế Anh
DECLARE cur_Admin CURSOR FOR 
    SELECT name FROM sys.tables WHERE name LIKE 'DanhSach%'; 

OPEN cur_Admin;
FETCH NEXT FROM cur_Admin INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- 2. Với mỗi bảng, ta tạo một câu lệnh "Kiểm tra và tối ưu hóa bảng"
    SET @Sql = 'DBCC CHECKTABLE (' + QUOTENAME(@TableName) + ');';
    
    PRINT N'Đang bảo trì bảng: ' + @TableName;
    
    -- 3. Thực thi câu lệnh vừa xây dựng động
    EXEC sp_executesql @Sql;

    FETCH NEXT FROM cur_Admin INTO @TableName;
END

CLOSE cur_Admin;
DEALLOCATE cur_Admin;

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/0c98b7fe-bc3d-404f-8cc0-79f868370263" />

* KẾT LUẬN VỀ SỰ KHÁC BIỆT GIỮA CURSOR VÀ SET-BASED SQL

Về bản chất xử lý:

Set-based (SELECT/UPDATE): Xử lý theo "Tập hợp". Giống như một chiếc máy gặt đập liên hợp, đi một đường là xử lý xong cả cánh đồng. Đây là lựa chọn tối ưu cho dữ liệu nghiệp vụ (điểm số, thông tin SV).

Cursor: Xử lý theo "Dòng". Giống như việc một người đi nhặt từng bông lúa. Chậm hơn nhưng lại cho phép kiểm tra kỹ lưỡng từng đối tượng một.

Phạm vi ứng dụng:

SQL thuần (Không dùng Cursor): Là "Vua" trong việc thao tác dữ liệu (DML). Luôn được ưu tiên hàng đầu để đảm bảo hiệu suất hệ thống.

Cursor: Là "Cứu cánh" duy nhất trong các tác vụ Quản trị hệ thống (Database Administration), xử lý Metadata, hoặc các logic nghiệp vụ phức tạp đòi hỏi phải thực thi các câu lệnh SQL động mà tại thời điểm viết code chúng ta chưa biết rõ đối tượng tác động là gì.

Tóm lại: "Làm việc với Dữ liệu thì dùng SELECT, làm việc với Cấu trúc và Quản trị thì hãy gọi Cursor."










  


  
