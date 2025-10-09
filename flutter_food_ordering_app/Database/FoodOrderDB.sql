CREATE DATABASE FoodOrderDB;
GO

USE FoodOrderDB;
GO

-- Tạo bảng NguoiDung
CREATE TABLE NguoiDung (
    MaNguoiDung INT PRIMARY KEY IDENTITY(1,1),
    TenDangNhap NVARCHAR(50) UNIQUE NOT NULL,
    MatKhau NVARCHAR(255) NOT NULL,
    HoTen NVARCHAR(100),
    Email NVARCHAR(100) UNIQUE,
    SoDienThoai NVARCHAR(20),
    DiaChi NVARCHAR(255),
    NgayTao DATETIME DEFAULT GETDATE()
);

-- Tạo bảng NhaHang
CREATE TABLE NhaHang (
    MaNhaHang INT PRIMARY KEY IDENTITY(1,1),
    TenNhaHang NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255),
    SoDienThoai NVARCHAR(20),
    MoTa NVARCHAR(500),
    NgayTao DATETIME DEFAULT GETDATE()
);

-- Tạo bảng MonAn 
CREATE TABLE MonAn (
    MaMonAn INT PRIMARY KEY IDENTITY(1,1),
    MaNhaHang INT NOT NULL,
    TenMonAn NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(500),
    Gia DECIMAL(10,2) NOT NULL,
    URLHinhAnh NVARCHAR(255),
    NgayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaNhaHang) REFERENCES NhaHang(MaNhaHang)
);

-- Tạo bảng DonHang 
CREATE TABLE DonHang (
    MaDonHang INT PRIMARY KEY IDENTITY(1,1),
    MaNguoiDung INT NOT NULL,
    MaNhaHang INT NOT NULL,
    NgayDatHang DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(10,2) NOT NULL,
    TrangThai NVARCHAR(50) NOT NULL,
    DiaChiGiaoHang NVARCHAR(200) NULL,
    SoDienThoai VARCHAR(20) NULL,
    GhiChu NVARCHAR(500) NULL,
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung),
    FOREIGN KEY (MaNhaHang) REFERENCES NhaHang(MaNhaHang)
);

-- Tạo bảng ChiTietDonHang
CREATE TABLE ChiTietDonHang (
    MaChiTietDonHang INT PRIMARY KEY IDENTITY(1,1),
    MaDonHang INT NOT NULL,
    MaMonAn INT NOT NULL,
    SoLuong INT NOT NULL,
    Gia DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (MaDonHang) REFERENCES DonHang(MaDonHang),
    FOREIGN KEY (MaMonAn) REFERENCES MonAn(MaMonAn)
);
-- Tạo bảng GioHang
CREATE TABLE GioHang (
    MaGioHang INT PRIMARY KEY IDENTITY(1,1),
    MaNguoiDung INT NOT NULL,
    MaMonAn INT NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    NgayThem DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung),
    FOREIGN KEY (MaMonAn) REFERENCES MonAn(MaMonAn)
);

-- Tạo bảng ThanhToan 
CREATE TABLE ThanhToan (
    MaThanhToan INT PRIMARY KEY IDENTITY(1,1),
    MaDonHang INT NOT NULL,
    NgayThanhToan DATETIME DEFAULT GETDATE(),
    SoTien DECIMAL(10,2) NOT NULL,
    PhuongThucThanhToan NVARCHAR(50) NOT NULL,
    TrangThai NVARCHAR(50) NOT NULL,
    FOREIGN KEY (MaDonHang) REFERENCES DonHang(MaDonHang)
);

-- Tạo bảng DanhGia 
CREATE TABLE DanhGia (
    MaDanhGia INT PRIMARY KEY IDENTITY(1,1),
    MaNguoiDung INT NOT NULL,
    MaNhaHang INT NOT NULL,
    DiemDanhGia INT NOT NULL CHECK (DiemDanhGia >= 1 AND DiemDanhGia <= 5),
    BinhLuan NVARCHAR(500),
    NgayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaNguoiDung) REFERENCES NguoiDung(MaNguoiDung),
    FOREIGN KEY (MaNhaHang) REFERENCES NhaHang(MaNhaHang)
);
-- Tạo bảng lịch sử chat
CREATE TABLE ChatHistory (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    UserMessage NVARCHAR(500) NOT NULL,
    BotResponse NVARCHAR(2000) NOT NULL,
    Timestamp DATETIME DEFAULT GETDATE() NOT NULL,
    FOREIGN KEY (UserId) REFERENCES NguoiDung(MaNguoiDung)
);
GO