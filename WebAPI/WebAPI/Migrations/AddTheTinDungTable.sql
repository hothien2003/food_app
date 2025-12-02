-- Migration: AddTheTinDungTable
-- Created: 2025-12-02

CREATE TABLE [dbo].[TheTinDung] (
    [MaThe] INT IDENTITY(1,1) NOT NULL,
    [MaNguoiDung] INT NOT NULL,
    [SoThe] NVARCHAR(20) NOT NULL,
    [TenChuThe] NVARCHAR(100) NOT NULL,
    [ThangHetHan] NVARCHAR(2) NOT NULL,
    [NamHetHan] NVARCHAR(2) NOT NULL,
    [MaBaoMat] NVARCHAR(4) NOT NULL,
    [LoaiThe] NVARCHAR(20) NOT NULL DEFAULT 'visa',
    [ChoPhepXoa] BIT NOT NULL DEFAULT 1,
    [NgayThem] DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK__TheTinDung] PRIMARY KEY CLUSTERED ([MaThe] ASC),
    CONSTRAINT [FK_TheTinDung_NguoiDung] FOREIGN KEY ([MaNguoiDung]) REFERENCES [dbo].[NguoiDung]([MaNguoiDung])
);

GO

CREATE INDEX [IX_TheTinDung_MaNguoiDung] ON [dbo].[TheTinDung]([MaNguoiDung]);
GO
