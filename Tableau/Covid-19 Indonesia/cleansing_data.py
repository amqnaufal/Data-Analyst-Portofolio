import pandas as pd

# 1. LOAD DATA
nama_file = 'covid_19_indonesia_time_series_translated.csv'
print(f"Sedang membaca file: {nama_file}...")
df = pd.read_csv(nama_file)

# 2. CLEANING (Membuang kolom yang 100% kosong)
# Sesuai filemu, kolom 'Kota atau Kabupaten' dan 'Unnamed: 38' itu kosong.
cols_to_drop = ['Kota atau Kabupaten', 'Unnamed: 38']
df = df.drop(columns=cols_to_drop)

# 3. FIXING NULLS
# Isi Provinsi yang kosong dengan 'Nasional'
df['Provinsi'] = df['Provinsi'].fillna('Indonesia (National)')

# 4. DATA TRANSFORMATION
# Ubah Tanggal ke format yang benar agar Tableau bisa buat grafik tren
df['Tanggal'] = pd.to_datetime(df['Tanggal'])

# 5. EXPORT HASIL BERSIH
df.to_csv('covid_hasil_bersih.csv', index=False)

print("-" * 30)
print("PROSES SELESAI!")
print(f"Data asli: {len(df)} baris.")
print("File baru 'covid_hasil_bersih.csv' sudah tercipta di foldermu.")
print("-" * 30)