using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebAPI.Models;

namespace WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TheTinDungController : ControllerBase
    {
        private readonly FoodOrderDBContext _context;

        public TheTinDungController(FoodOrderDBContext context)
        {
            _context = context;
        }

        // GET: api/TheTinDung/User/5
        [HttpGet("User/{maNguoiDung}")]
        public async Task<ActionResult<IEnumerable<object>>> GetTheByUserId(int maNguoiDung)
        {
            var cards = await _context.TheTinDungs
                .Where(t => t.MaNguoiDung == maNguoiDung)
                .OrderByDescending(t => t.NgayThem)
                .Select(t => new
                {
                    t.MaThe,
                    t.MaNguoiDung,
                    SoThe = "****" + t.SoThe.Substring(Math.Max(0, t.SoThe.Length - 4)),
                    t.TenChuThe,
                    t.ThangHetHan,
                    t.NamHetHan,
                    t.LoaiThe,
                    t.ChoPhepXoa,
                    t.NgayThem
                })
                .ToListAsync();

            return Ok(cards);
        }

        // GET: api/TheTinDung/5
        [HttpGet("{id}")]
        public async Task<ActionResult<TheTinDung>> GetTheTinDung(int id)
        {
            var theTinDung = await _context.TheTinDungs.FindAsync(id);

            if (theTinDung == null)
            {
                return NotFound();
            }

            return theTinDung;
        }

        // POST: api/TheTinDung
        [HttpPost]
        public async Task<ActionResult<TheTinDung>> PostTheTinDung(TheTinDung theTinDung)
        {
            try
            {
                // Kiểm tra người dùng có tồn tại không
                var nguoiDung = await _context.NguoiDungs.FindAsync(theTinDung.MaNguoiDung);
                if (nguoiDung == null)
                {
                    return BadRequest(new { message = "Người dùng không tồn tại" });
                }

                // Kiểm tra số thẻ đã tồn tại chưa
                var existingCard = await _context.TheTinDungs
                    .FirstOrDefaultAsync(t => t.SoThe == theTinDung.SoThe && t.MaNguoiDung == theTinDung.MaNguoiDung);
                
                if (existingCard != null)
                {
                    return BadRequest(new { message = "Thẻ này đã được thêm trước đó" });
                }

                theTinDung.NgayThem = DateTime.Now;
                
                _context.TheTinDungs.Add(theTinDung);
                await _context.SaveChangesAsync();

                // Trả về với số thẻ bị che
                var result = new
                {
                    theTinDung.MaThe,
                    theTinDung.MaNguoiDung,
                    SoThe = "****" + theTinDung.SoThe.Substring(Math.Max(0, theTinDung.SoThe.Length - 4)),
                    theTinDung.TenChuThe,
                    theTinDung.ThangHetHan,
                    theTinDung.NamHetHan,
                    theTinDung.LoaiThe,
                    theTinDung.ChoPhepXoa,
                    theTinDung.NgayThem
                };

                return CreatedAtAction(nameof(GetTheTinDung), new { id = theTinDung.MaThe }, result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi thêm thẻ: " + ex.Message });
            }
        }

        // DELETE: api/TheTinDung/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTheTinDung(int id)
        {
            var theTinDung = await _context.TheTinDungs.FindAsync(id);
            if (theTinDung == null)
            {
                return NotFound(new { message = "Thẻ không tồn tại" });
            }

            if (!theTinDung.ChoPhepXoa)
            {
                return BadRequest(new { message = "Thẻ này không được phép xóa" });
            }

            _context.TheTinDungs.Remove(theTinDung);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa thẻ thành công" });
        }

        private bool TheTinDungExists(int id)
        {
            return _context.TheTinDungs.Any(e => e.MaThe == id);
        }
    }
}
