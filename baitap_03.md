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

