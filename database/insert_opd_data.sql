-- Insert OPD data dengan kode OPD yang di-generate otomatis
-- Kode OPD akan menggunakan format: DP-001, DP-002, dst untuk Dinas
-- BP-001, BP-002, dst untuk Badan
-- BR-001, BR-002, dst untuk Biro
-- IN-001 untuk Inspektorat
-- SP-001 untuk Satuan Polisi
-- RS-001, RS-002, dst untuk Rumah Sakit

INSERT INTO opd (kode_opd, nama_opd) VALUES
-- Dinas (DP-001 sampai DP-021)
('DP-001', 'Dinas Perpustakaan dan Kearsipan'),
('DP-002', 'Dinas Pemberdayaan Perempuan, Perlindungan Anak, Kependudukan dan Keluarga Berencana'),
('DP-003', 'Dinas Lingkungan Hidup dan Kehutanan'),
('DP-004', 'Dinas Ketahanan Pangan'),
('DP-005', 'Dinas Perumahan Rakyat dan Kawasan Permukiman'),
('DP-006', 'Dinas Pekerjaan Umum dan Penataan Ruang'),
('DP-007', 'Dinas Kesehatan'),
('DP-008', 'Dinas Pendidikan dan Kebudayaan'),
('DP-009', 'Dinas Kepemudaan dan Olah Raga'),
('DP-010', 'Dinas Pertanian'),
('DP-011', 'Dinas Kelautan dan Perikanan'),
('DP-012', 'Dinas Penanaman Modal dan Pelayanan Terpadu Satu Pintu'),
('DP-013', 'Dinas Pemberdayaan Masyarakat dan Desa'),
('DP-014', 'Dinas Komunikasi, Informatika, Statistik dan Persandian'),
('DP-015', 'Dinas Perhubungan'),
('DP-016', 'Dinas Energi dan Sumberdaya Mineral'),
('DP-017', 'Dinas Perindustrian dan Perdagangan'),
('DP-018', 'Dinas Pariwisata'),
('DP-019', 'Dinas Sosial'),
('DP-020', 'Dinas Tenaga Kerja dan Transmigrasi'),
('DP-021', 'Dinas Koperasi, Usaha Kecil dan Menengah'),

-- Biro (BR-001 sampai BR-008)
('BR-001', 'Biro Administrasi Pimpinan'),
('BR-002', 'Biro Perekonomian dan Administrasi Pembangunan'),
('BR-003', 'Biro Pemerintahan dan Otonomi Daerah Setda Provinsi Banten'),
('BR-004', 'Biro Hukum'),
('BR-005', 'Biro Organisasi dan Reformasi Birokrasi'),
('BR-006', 'Biro Umum'),
('BR-007', 'Biro Pengadaan Barang / Jasa dan LPSE'),

-- Inspektorat (IN-001)
('IN-001', 'Inspektorat'),

-- Badan (BP-001 sampai BP-007)
('BP-001', 'Badan Pengelolaan Keuangan dan Aset Daerah'),
('BP-002', 'Badan Kepegawaian Daerah'),
('BP-003', 'Badan Pengembangan Sumber Daya Manusia'),
('BP-004', 'Badan Kesatuan Bangsa dan Politik'),
('BP-005', 'Badan Pendapatan Daerah'),
('BP-006', 'Badan Perencanaan Pembangunan Daerah'),
('BP-007', 'Badan Penanggulangan Bencana Daerah'),
('BP-008', 'Badan Penghubung'),

-- Satuan Polisi (SP-001)
('SP-001', 'Satuan Polisi Pamong Praja (SATPOLPP) Provinsi Banten'),

-- Rumah Sakit (RS-001 sampai RS-004)
('RS-001', 'Rumah Sakit Umum Daerah'),
('RS-002', 'Rumah Sakit Umum Malimping'),
('RS-003', 'Rumah Sakit Labuan'),
('RS-004', 'Rumah Sakit Cilograng');
