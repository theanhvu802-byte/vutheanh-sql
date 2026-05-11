
-- 1. TẠO CẤU TRÚC BẢNG (3NF)
IF OBJECT_ID('LogBienDong', 'U') IS NOT NULL DROP TABLE LogBienDong;
IF OBJECT_ID('TaiSan', 'U') IS NOT NULL DROP TABLE TaiSan;
IF OBJECT_ID('HopDong', 'U') IS NOT NULL DROP TABLE HopDong;
IF OBJECT_ID('KhachHang', 'U') IS NOT NULL DROP TABLE KhachHang;
IF OBJECT_ID('NhanVien', 'U') IS NOT NULL DROP TABLE NhanVien;
GO

CREATE TABLE KhachHang (
    MaKH INT IDENTITY(1,1) PRIMARY KEY,
    HoTen NVARCHAR(100),
    SoDienThoai VARCHAR(15),
    CCCD VARCHAR(20)
);

CREATE TABLE NhanVien (
    MaNV INT IDENTITY(1,1) PRIMARY KEY,
    TenNV NVARCHAR(100),
    ChucVu NVARCHAR(50)
);

CREATE TABLE HopDong (
    MaHD INT IDENTITY(1,1) PRIMARY KEY,
    MaKH INT FOREIGN KEY REFERENCES KhachHang(MaKH),
    MaNV INT FOREIGN KEY REFERENCES NhanVien(MaNV),
    NgayVay DATETIME,
    SoTienVayGoc DECIMAL(18,2),
    LaiSuatNgay FLOAT DEFAULT 0.001, -- 0.1% mỗi ngày
    Deadline1 DATETIME,
    Deadline2 DATETIME,
    TrangThai NVARCHAR(50) DEFAULT N'Đang vay'
);

CREATE TABLE TaiSan (
    MaTS INT IDENTITY(1,1) PRIMARY KEY,
    MaHD INT FOREIGN KEY REFERENCES HopDong(MaHD),
    TenTaiSan NVARCHAR(200),
    GiaTriDinhGia DECIMAL(18,2),
    TrangThaiTS NVARCHAR(50) DEFAULT N'Đang cầm cố'
);

CREATE TABLE LogBienDong (
    MaLog INT IDENTITY(1,1) PRIMARY KEY,
    MaHD INT,
    MaNV INT,
    NgayGiaoDich DATETIME DEFAULT GETDATE(),
    SoTienTra DECIMAL(18,2),
    NoiDung NVARCHAR(255),
    DuNoSauGiaoDich DECIMAL(18,2)
);
GO

-- 2. HÀM TÍNH LÃI (LOGIC LÃI KÉP)
CREATE OR ALTER FUNCTION fn_TheAnh_CalcMoneyTransaction(@MaHD INT, @NgayCheck DATETIME)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Goc DECIMAL(18,2), @NgayVay DATETIME, @Deadline1 DATETIME, @Lai FLOAT;
    SELECT @Goc = SoTienVayGoc, @NgayVay = NgayVay, @Deadline1 = Deadline1, @Lai = LaiSuatNgay 
    FROM HopDong WHERE MaHD = @MaHD;

    DECLARE @SoNgay INT = DATEDIFF(DAY, @NgayVay, @NgayCheck);
    IF @NgayCheck <= @Deadline1
        RETURN @Goc + (@Goc * @Lai * @SoNgay);
    
    DECLARE @SoNgayQuaHan INT = DATEDIFF(DAY, @Deadline1, @NgayCheck);
    RETURN @Goc * POWER(1 + @Lai, @SoNgayQuaHan);
END;
GO

-- 3. CÁC TRIGGER TỰ ĐỘNG (EVENT 5)
CREATE TRIGGER trg_TheAnh_AutoProcess
ON HopDong
AFTER UPDATE
AS
BEGIN
    -- Chuyển sang Quá hạn
    UPDATE HopDong SET TrangThai = N'Quá hạn (nợ xấu)'
    FROM HopDong JOIN inserted i ON HopDong.MaHD = i.MaHD
    WHERE HopDong.TrangThai = N'Đang vay' AND GETDATE() > HopDong.Deadline1;

    -- Sẵn sàng thanh lý
    UPDATE TaiSan SET TrangThaiTS = N'Sẵn sàng thanh lý'
    FROM TaiSan JOIN inserted i ON TaiSan.MaHD = i.MaHD
    WHERE i.TrangThai = N'Quá hạn (nợ xấu)' AND GETDATE() > i.Deadline2;
END;
GO

-- 4. NẠP DỮ LIỆU MẪU (SAMPLE DATA)
INSERT INTO KhachHang (HoTen, SoDienThoai, CCCD) VALUES (N'Nguyễn Văn A', '0912345678', '001099001234');
INSERT INTO NhanVien (TenNV, ChucVu) VALUES (N'Trần Thị B', N'Quản lý');

-- Hợp đồng lùi ngày để demo lãi quá hạn (Vay từ 45 ngày trước)
INSERT INTO HopDong (MaKH, MaNV, NgayVay, SoTienVayGoc, Deadline1, Deadline2, TrangThai)
VALUES (1, 1, DATEADD(DAY, -45, GETDATE()), 10000000, DATEADD(DAY, -15, GETDATE()), DATEADD(DAY, 15, GETDATE()), N'Đang vay');

INSERT INTO TaiSan (MaHD, TenTaiSan, GiaTriDinhGia, TrangThaiTS)
VALUES (1, N'iPhone 15 Pro Max', 30000000, N'Đang cầm cố');
GO

-- 5. TRUY VẤN KIỂM TRA (EVENT 4)
SELECT 
    K.HoTen AS [Khách Hàng],
    H.SoTienVayGoc AS [Tiền Gốc],
    dbo.fn_TheAnh_CalcMoneyTransaction(H.MaHD, GETDATE()) AS [Nợ Hiện Tại],
    dbo.fn_TheAnh_CalcMoneyTransaction(H.MaHD, DATEADD(MONTH, 1, GETDATE())) AS [Dự Báo 30 Ngày Sau]
FROM HopDong H JOIN KhachHang K ON H.MaKH = K.MaKH;
