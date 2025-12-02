using System;
using System.Collections.Generic;

namespace WebAPI.Models;

public partial class TinNhan
{
    public int MaTinNhan { get; set; }

    public int? MaNguoiDung { get; set; }

    public string TieuDe { get; set; } = null!;

    public string NoiDung { get; set; } = null!;

    public DateTime NgayGui { get; set; } = DateTime.Now;

    public bool DaDoc { get; set; } = false;

    public string LoaiTinNhan { get; set; } = "promotion";

    public virtual NguoiDung? MaNguoiDungNavigation { get; set; }
}
