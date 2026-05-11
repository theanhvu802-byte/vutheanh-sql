* Tên : Vũ Thế Anh

* Lớp : K59KMT.K01

# Nhiệm vụ 1 :

```
CREATE DATABASE QuanLyCamDo_TheAnh;
GO
USE QuanLyCamDo_TheAnh;
GO

-- Mục 1: Bảng Khách hàng
CREATE TABLE KhachHang (
    MaKH INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(15),
    CCCD VARCHAR(12) UNIQUE NOT NULL
);

-- Mục 2: Bảng Nhân viên (Để quản lý người thu tiền)
CREATE TABLE NhanVien (
    MaNV INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    ChucVu NVARCHAR(50)
);

-- Mục 3: Bảng Hợp đồng (Quản lý Deadline1 và Deadline2)
CREATE TABLE HopDong (
    MaHD INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT FOREIGN KEY REFERENCES KhachHang(MaKH),
    NgayVay DATETIME DEFAULT GETDATE(),
    SoTienVayGoc DECIMAL(18,2) NOT NULL,
    Deadline1 DATE NOT NULL, 
    Deadline2 DATE NOT NULL,
    TrangThai NVARCHAR(50) DEFAULT N'Đang vay'
);

-- Mục 4: Bảng Tài sản (Theo dõi trạng thái tài sản)
CREATE TABLE TaiSan (
    MaTS INT PRIMARY KEY IDENTITY(1,1),
    MaHD INT FOREIGN KEY REFERENCES HopDong(MaHD),
    TenTaiSan NVARCHAR(100) NOT NULL,
    GiaTriDinhGia DECIMAL(18,2),
    TrangThaiTS NVARCHAR(50) DEFAULT N'Đang cầm cố' -- Đang cầm, đã trả, đã bán
);

-- Mục 5: Bảng Audit Log (Lịch sử dòng tiền)
CREATE TABLE LogBienDong (
    MaLog INT PRIMARY KEY IDENTITY(1,1),
    MaHD INT FOREIGN KEY REFERENCES HopDong(MaHD),
    MaNV INT FOREIGN KEY REFERENCES NhanVien(MaNV),
    NgayGiaoDich DATETIME DEFAULT GETDATE(),
    SoTienTra DECIMAL(18,2),
    NoiDung NVARCHAR(MAX)
);
```
<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-05-10 160813" src="https://github.com/user-attachments/assets/6593fb53-0581-4de5-957f-d8869604bf6c" />

Em đã hoàn thành thiết kế hệ thống với 5 thực thể chính, tập trung vào việc tối ưu hóa khả năng truy vết dòng tiền (Audit Log). Bằng việc tách biệt bảng Nhật ký và Hợp đồng, hệ thống cho phép ghi lại từng giao dịch nhỏ nhất của khách hàng, giúp đảm bảo tính minh bạch, chống thất thoát và phục vụ tốt công tác đối soát dữ liệu sau này

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/6fdc034c-25d5-45eb-acf8-58ac90a21c1a" />

* 1.1 Chuẩn hóa thực thể Hợp đồng
Mục tiêu: Chỉ lưu trữ các thông tin cốt lõi của khoản vay và tham chiếu tới khách hàng.

<img width="550" height="348" alt="image" src="https://github.com/user-attachments/assets/93e1a0e9-17a2-4546-a398-b27b69e8d90e" />

* 1.2 Danh mục các bảng chi tiết
* Bảng KhachHang (Danh mục Khách hàng)
Giúp quản lý thông tin định danh khách hàng, tránh lặp lại thông tin cá nhân trong mỗi hợp đồng.

<img width="710" height="285" alt="image" src="https://github.com/user-attachments/assets/bf971785-812d-49a8-87b7-06694caeda19" />

* Bảng NhanVien (Danh mục Nhân viên)
Lưu thông tin nhân viên thu tiền để đảm bảo tính minh bạch.

<img width="686" height="193" alt="image" src="https://github.com/user-attachments/assets/705f0cf0-b3fa-445d-9494-993f22fb9df6" />

* Bảng LogBienDong (Nhật ký giao dịch - Audit Log)
Ghi nhận từng lần khách trả tiền, là "nguồn sự thật duy nhất" cho lịch sử dòng tiền.

<img width="683" height="280" alt="image" src="https://github.com/user-attachments/assets/0be67e77-2875-490f-ba4b-a94b7429eac9" />



 # Nhiệm vụ 2: Cài đặt SQL (Yêu cầu viết Scripts)

 * Event 1: Đăng ký hợp đồng mới (Vay tiền)
   
* Viết Store Procedure tiếp nhận hợp đồng: Lưu thông tin khách hàng, danh sách tài sản 
(kèm giá trị định giá), số tiền vay gốc và thiết lập 2 mốc Deadline1, Deadline2.
```

CREATE PROCEDURE sp_TheAnh_DangKyHopDong
    @HoTen NVARCHAR(100),
    @SDT VARCHAR(15),
    @CCCD VARCHAR(12),
    @SoTienVayGoc DECIMAL(18,2), -- Khớp với thuộc tính 3NF
    @Deadline1 DATE,
    @Deadline2 DATE,
    @TenTaiSan NVARCHAR(100),
    @GiaTriDinhGia DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MaKH_Moi INT;

    -- 1. Kiểm tra khách hàng dựa trên CCCD (Đảm bảo 3NF) [cite: 32]
    IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE CCCD = @CCCD)
    BEGIN
        INSERT INTO KhachHang (HoTen, SoDienThoai, CCCD)
        VALUES (@HoTen, @SDT, @CCCD);
        SET @MaKH_Moi = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SELECT @MaKH_Moi = MaKH FROM KhachHang WHERE CCCD = @CCCD;
    END

    -- 2. Tạo Hợp đồng mới (Sử dụng SoTienVayGoc) [cite: 11]
    INSERT INTO HopDong (MaKH, NgayVay, SoTienVayGoc, Deadline1, Deadline2, TrangThai)
    VALUES (@MaKH_Moi, GETDATE(), @SoTienVayGoc, @Deadline1, @Deadline2, N'Đang vay');

    DECLARE @MaHD_Moi INT = SCOPE_IDENTITY();

    -- 3. Lưu thông tin tài sản thế chấp (Tách riêng để đảm bảo 1NF) [cite: 29]
    INSERT INTO TaiSan (MaHD, TenTaiSan, GiaTriDinhGia, TrangThaiTS)
    VALUES (@MaHD_Moi, @TenTaiSan, @GiaTriDinhGia, N'Đang cầm cố');

    PRINT N'Hợp đồng của khách ' + @HoTen + N' đã được Vũ Thế Anh khởi tạo thành công!';
END;
GO

--- chạy demo 
EXEC sp_TheAnh_DangKyHopDong 
    @HoTen = N'Nguyễn Văn A', 
    @SDT = '0912345678', 
    @CCCD = '001099001234', 
    @SoTienVayGoc = 10000000, 
    @Deadline1 = '2026-06-01', 
    @Deadline2 = '2026-07-01', 
    @TenTaiSan = N'Laptop Dell XPS', 
    @GiaTriDinhGia = 25000000;

    SELECT * FROM HopDong;
```
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/df544714-84fa-4ca3-9444-e561d6079df5" />

*Để kiểm tra tính chính xác của dữ liệu sau khi thực hiện Event 1, em đã sử dụng các câu lệnh truy vấn có liên kết bảng (JOIN). Việc truy vấn này cho phép hiển thị đầy đủ thông tin từ các bảng đã chuẩn hóa, giúp chủ tiệm dễ dàng đối soát giữa thông tin khách hàng, chi tiết tài sản cầm cố và các mốc thời gian trả nợ đã thiết lập trong hợp đồng.*

* Event 2: Tính toán công nợ thời gian thực
Viết một Function fn_CalcMoneyTransaction(TransactionID, TargetDate) để tính số tiền 
phải trả của TransactionID này cho đến ngày TargetDate
```
-- ==========================================================
-- EVENT 2: TÍNH TOÁN CÔNG NỢ THỜI GIAN THỰC
-- SV thực hiện: Vũ Thế Anh | MSSV: K235480106004
-- ==========================================================

CREATE FUNCTION fn_TheAnh_CalcMoneyContract (@MaHD INT, @TargetDate DATETIME)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Goc DECIMAL(18,2), @NgayVay DATETIME, @DL1 DATE;
    DECLARE @TongNo DECIMAL(18,2);
    DECLARE @r FLOAT = 0.005; -- Lãi suất 0.5%/ngày

    -- Lấy thông tin gốc và ngày vay từ bảng HopDong
    SELECT @Goc = SoTienVayGoc, @NgayVay = NgayVay, @DL1 = Deadline1 
    FROM HopDong WHERE MaHD = @MaHD;

    -- TRƯỜNG HỢP 1: Chưa quá hạn Deadline 1 (Tính lãi đơn)
    IF @TargetDate <= @DL1
    BEGIN
        DECLARE @n1 INT = DATEDIFF(DAY, @NgayVay, @TargetDate);
        IF @n1 < 0 SET @n1 = 0;
        SET @TongNo = @Goc * (1 + @r * @n1);
    END
    -- TRƯỜNG HỢP 2: Đã quá hạn Deadline 1 (Tính lãi kép)
    ELSE
    BEGIN
        -- B1: Tính tổng nợ tại mốc Deadline 1 (Lãi đơn kết thúc)
        DECLARE @n_don INT = DATEDIFF(DAY, @NgayVay, @DL1);
        DECLARE @P_at_DL1 DECIMAL(18,2) = @Goc * (1 + @r * @n_don);
        
        -- B2: Tính lãi kép từ Deadline 1 đến TargetDate
        DECLARE @n_kep INT = DATEDIFF(DAY, @DL1, @TargetDate);
        SET @TongNo = @P_at_DL1 * CAST(POWER(1 + @r, @n_kep) AS DECIMAL(18,2));
    END

    RETURN @TongNo;
END;
GO
```
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/11c9ef32-7388-4077-af9a-5662bf461493" />

*Viết một Function fn_CalcMoneyContract(ContractID, TargetDate) để tính tổng số tiền 
khách(ContractID) phải trả (Gốc + Lãi đơn + Lãi kép) tính đến ngày TargetDate.

```
CREATE FUNCTION fn_TheAnh_CalcMoneyTransaction (@MaHD INT, @TargetDate DATETIME)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongNoPhaiTra DECIMAL(18,2);
    DECLARE @DaTra DECIMAL(18,2);

    -- 1. Tính tổng nợ gốc + lãi đến ngày TargetDate
    SET @TongNoPhaiTra = dbo.fn_TheAnh_CalcMoneyContract(@MaHD, @TargetDate);

    -- 2. Tính tổng tiền khách đã trả trong lịch sử (Audit Log)
    SELECT @DaTra = ISNULL(SUM(SoTienTra), 0) 
    FROM LogBienDong 
    WHERE MaHD = @MaHD AND NgayGiaoDich <= @TargetDate;

    RETURN @TongNoPhaiTra - @DaTra;
END;
GO
```

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/1aca00f0-ddbf-4086-b2c7-430bf7d1a361" />
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/0f56de74-14b7-4274-8499-e918d2ad9b91" />

*Trong Event 2, em đã cài đặt hai hàm xử lý tài chính cốt lõi. Hàm fn_TheAnh_CalcMoneyContract sử dụng cấu trúc rẽ nhánh để phân định hai giai đoạn tính lãi: lãi đơn theo ngày và lãi kép lũy thừa (sử dụng hàm POWER) khi khách hàng vượt quá mốc Deadline1. Đặc biệt, hàm fn_TheAnh_CalcMoneyTransaction thể hiện rõ sức mạnh của Audit Log bằng cách đối soát thời gian thực giữa tổng nợ phát sinh và các khoản thanh toán lẻ được lưu trong bảng LogBienDong, giúp chủ tiệm luôn nắm bắt được dư nợ thực tế của khách hàng mà không làm sai lệch dữ liệu gốc.*


* Event 3: Xử lý trả nợ và hoàn trả tài sản
Viết Viết Store Procedure xử lý khi khách mang tiền đến:
Nếu tài sản đã bị thanh lý (sau Deadline 2 và có cờ IsSold): Thông báo không thu tiền, 
không trả đồ.
Nếu tài sản chưa bị thanh lý: Tính tổng nợ, trừ số tiền khách trả vào hệ thống. Nếu trả hết 
tiền, trả hết đồ và cập nhật trạng thái hợp đồng thành “Đã thanh toán đủ”; Nếu chưa trả
hết tiền gốc+lãi: cập nhật trạng thái hợp đồng thành “Đang trả góp”, ghi nhận vào LOG số
tiền đã trả, và số tiền còn nợ.
Đưa ra danh sách gợi ý trả lại cho khách hàng này dựa trên điều kiện: 
Giá trị tài sản còn lại >= Dư nợ còn lại.




