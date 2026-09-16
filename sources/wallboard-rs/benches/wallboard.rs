use criterion::{black_box, criterion_group, criterion_main, Criterion};
use wallboard::palette::Palette;
use wallboard::svg_gen::{draw_aa_line, render_wallpaper, DisplayDims};

/// Typical 13" MacBook Pro: 1512x982 logical, 3024x1964 physical.
fn typical_dims() -> DisplayDims {
    DisplayDims {
        logical_w: 1512,
        logical_h: 982,
        physical_w: 3024,
        physical_h: 1964,
    }
}

fn bench_render_wallpaper(c: &mut Criterion) {
    let dims = typical_dims();
    let palette = Palette::build();

    c.bench_function("render_wallpaper (5000 lines, 3024x1964)", |b| {
        b.iter(|| render_wallpaper(black_box(&dims), black_box(&palette)))
    });
}

fn bench_draw_aa_line(c: &mut Criterion) {
    let w = 3024;
    let h = 1964;
    let mut buf = vec![0u8, w * h * 4];

    // A representative diagonal line spanning a good portion of the canvas
    c.bench_function("draw_aa_line (single, ~1500px diagonal)", |b| {
        b.iter(|| {
            draw_aa_line(
                &mut buf, w, h,
                200.0, 300.0,
                1700.0, 1400.0,
                2.5,
                200, 100, 50,
            )
        })
    });

    // A short line (more typical of the 50-100px lengths in the generator)
    c.bench_function("draw_aa_line (single, ~75px short)", |b| {
        b.iter(|| {
            draw_aa_line(
                &mut buf, w, h,
                1000.0, 800.0,
                1075.0, 850.0,
                1.8,
                50, 200, 100,
            )
        })
    });
}

fn bench_encode_png(c: &mut Criterion) {
    let w = 3024u32;
    let h = 1964u32;
    // Fill with a non-trivial pattern (not all zeros, to exercise the encoder)
    let rgba: Vec<u8> = (0..(w as usize * h as usize * 4))
        .map(|i| (i % 256) as u8)
        .collect();

    c.bench_function("encode_png (3024x1964 RGBA)", |b| {
        b.iter(|| {
            let mut encoder = png::Encoder::new(std::io::sink(), w, h);
            encoder.set_color(png::ColorType::Rgba);
            encoder.set_depth(png::BitDepth::Eight);
            let mut writer = encoder.write_header().unwrap();
            writer.write_image_data(black_box(&rgba)).unwrap();
        })
    });
}

criterion_group!(
    benches,
    bench_render_wallpaper,
    bench_draw_aa_line,
    bench_encode_png,
);
criterion_main!(benches);
