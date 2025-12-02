-- Migration: AddTinNhanTable
-- Created: 2025-12-02

CREATE TABLE [dbo].[TinNhan] (
    [MaTinNhan] INT IDENTITY(1,1) NOT NULL,
    [MaNguoiDung] INT NULL,
    [TieuDe] NVARCHAR(200) NOT NULL,
    [NoiDung] NVARCHAR(1000) NOT NULL,
    [NgayGui] DATETIME NOT NULL DEFAULT GETDATE(),
    [DaDoc] BIT NOT NULL DEFAULT 0,
    [LoaiTinNhan] NVARCHAR(50) NOT NULL DEFAULT 'promotion',
    CONSTRAINT [PK__TinNhan] PRIMARY KEY CLUSTERED ([MaTinNhan] ASC),
    CONSTRAINT [FK_TinNhan_NguoiDung] FOREIGN KEY ([MaNguoiDung]) REFERENCES [dbo].[NguoiDung]([MaNguoiDung]) ON DELETE SET NULL
);

GO

CREATE INDEX [IX_TinNhan_MaNguoiDung] ON [dbo].[TinNhan]([MaNguoiDung]);
GO

-- Thêm một số tin nhắn mẫu công khai
INSERT INTO [dbo].[TinNhan] ([MaNguoiDung], [TieuDe], [NoiDung], [LoaiTinNhan]) VALUES
(NULL, N'Ưu đãi Thienmeal', N'Nhận ngay mã giảm 30% cho đơn hàng đầu tiên trong tuần này.', 'promotion'),
(NULL, N'Ưu đãi Thienmeal', N'Freeship cho đơn từ 200.000 đ tại mọi quận nội thành.', 'promotion'),
(NULL, N'Ưu đãi Thienmeal', N'Nhà hàng mới vừa mở bán, đặt bàn ngay để nhận quà tặng.', 'promotion'),
(NULL, N'Ưu đãi Thienmeal', N'Tích lũy thêm 50 điểm thưởng khi thanh toán qua ví điện tử.', 'promotion'),
(NULL, N'Ưu đãi Thienmeal', N'Combo trưa chỉ 69.000 đ áp dụng trong khung giờ 11h-14h.', 'promotion'),
(NULL, N'Ưu đãi Thienmeal', N'Giới thiệu bạn bè để nhận thêm 2 mã giảm giá độc quyền.', 'promotion');

GO
