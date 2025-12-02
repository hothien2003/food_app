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
    public class TinNhanController : ControllerBase
    {
        private readonly FoodOrderDBContext _context;

        public TinNhanController(FoodOrderDBContext context)
        {
            _context = context;
        }

        // GET: api/TinNhan/User/5
        [HttpGet("User/{maNguoiDung}")]
        public async Task<ActionResult<IEnumerable<TinNhan>>> GetTinNhanByUserId(int maNguoiDung)
        {
            // Lấy tin nhắn của người dùng cụ thể hoặc tin nhắn công khai (MaNguoiDung = null)
            var tinNhans = await _context.TinNhans
                .Where(t => t.MaNguoiDung == maNguoiDung || t.MaNguoiDung == null)
                .OrderByDescending(t => t.NgayGui)
                .ToListAsync();

            return Ok(tinNhans);
        }

        // GET: api/TinNhan/Public
        [HttpGet("Public")]
        public async Task<ActionResult<IEnumerable<TinNhan>>> GetPublicMessages()
        {
            var tinNhans = await _context.TinNhans
                .Where(t => t.MaNguoiDung == null)
                .OrderByDescending(t => t.NgayGui)
                .ToListAsync();

            return Ok(tinNhans);
        }

        // POST: api/TinNhan
        [HttpPost]
        public async Task<ActionResult<TinNhan>> PostTinNhan(TinNhan tinNhan)
        {
            try
            {
                tinNhan.NgayGui = DateTime.Now;
                tinNhan.DaDoc = false;

                _context.TinNhans.Add(tinNhan);
                await _context.SaveChangesAsync();

                return CreatedAtAction(nameof(GetTinNhanByUserId), new { maNguoiDung = tinNhan.MaNguoiDung }, tinNhan);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi gửi tin nhắn: " + ex.Message });
            }
        }

        // PUT: api/TinNhan/MarkAsRead/5
        [HttpPut("MarkAsRead/{id}")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var tinNhan = await _context.TinNhans.FindAsync(id);
            if (tinNhan == null)
            {
                return NotFound();
            }

            tinNhan.DaDoc = true;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/TinNhan/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTinNhan(int id)
        {
            var tinNhan = await _context.TinNhans.FindAsync(id);
            if (tinNhan == null)
            {
                return NotFound();
            }

            _context.TinNhans.Remove(tinNhan);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa tin nhắn thành công" });
        }
    }
}
