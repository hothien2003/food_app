using System;
using System.Collections.Generic;

namespace WebAPI.Models;

public partial class TheTinDung
{
    public int MaThe { get; set; }

    public int MaNguoiDung { get; set; }

    public string SoThe { get; set; } = null!;

    public string TenChuThe { get; set; } = null!;

    public string ThangHetHan { get; set; } = null!;

    public string NamHetHan { get; set; } = null!;

    public string MaBaoMat { get; set; } = null!;

    public string LoaiThe { get; set; } = "visa";

    public bool ChoPhepXoa { get; set; } = true;

    public DateTime NgayThem { get; set; } = DateTime.Now;

    public virtual NguoiDung MaNguoiDungNavigation { get; set; } = null!;
}
