class ApiWicara {
  static const baseUrl = "https://bedbug-tidy-halibut.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/api/mobile/";
  static const verifyQrUrl = "${baseUrl}check_qr_app.php";
  static const removeTokenUrl = "${baseUrl}logout_app.php";
  static const fetchProfileDataUrl = "${baseUrl}tampil_profile_app.php";
  static const fetchNotificationCountUrl = "${baseUrl}jumlah_notifikasi_app.php";
  static const loginUrl = "${baseUrl}simpan_login_app.php";
  static const fetchDataUnitLayananHomeUrl = "${baseUrl}ambil_data_unit_layanan_home_app.php";
  static const fetchDataUnitLayananDashboardUrl = "${baseUrl}ambil_data_unit_layanan_app.php";
  static const fetchDataAduanTerbaruUrl = "${baseUrl}ambil_data_aduan_terbaru_app.php";
  static const fetchUserDataHomeUrl = "${baseUrl}ambil_data_user_home_app.php";
  static const fetchInstansiInfoUrl = "${baseUrl}ambil_data_unit_layanan_untuk_rating_app.php";
  static const  submitRatingUrl = "${baseUrl}simpan_ulasan_app.php";
  static const submitPenemuanUrl = "${baseUrl}simpan_penemuan_app.php";
  static const submitKehilanganUrl = "${baseUrl}simpan_kehilangan_app.php";
  static const submitAduanUrl = "${baseUrl}simpan_aduan_app.php";
  static const fetchJenisPengaduanUrl = "${baseUrl}tampil_jenis_pengaduan_form_aduan_app.php";
  static const fetchInstansiInfoAduanUrl = "${baseUrl}tampil_instansi_form_aduan_app.php";
  static const updateProfileUrl = "${baseUrl}update_profile_app.php";
  static const fetchDetailUnitLayananUrl = "${baseUrl}ambil_data_detail_unit_layanan_app.php?id_instansi=";
  static const respondNoTemuanUrl = "${baseUrl}respon_tidak_temuan_app.php";
  static const respondYesTemuanUrl = "${baseUrl}respon_ya_temuan_app.php";
  static const  respondDoneTemuanUrl = "${baseUrl}respon_selesai_temuan_app.php";
  static const changeKehilanganStatusUrl = "${baseUrl}ganti_status_kehilangan_app.php";
  static const fetchNotificationDetailUrl = "${baseUrl}detail_notifikasi_app.php";
  static const fetchPengaduanAllUrl = "${baseUrl}ambil_pengaduan_app.php";
  static const fetchNotificationAllUrl = "${baseUrl}ambil_notifikasi_all_app.php";
  static const updateNotificationFlagUrl = "${baseUrl}update_flag_notifikasi_app.php";
  static const fetchKehilanganBelumDitemukanUrl = "${baseUrl}get_belum_ditemukan_app.php";
  static const fetchKehilanganSudahDitemukanUrl = "${baseUrl}get_ditemukan_app.php";
  static const fetchTemuanUrl = "${baseUrl}get_temuan_app.php";
  static const fetchRiwayatKehilanganUserUrl = "${baseUrl}get_riwayat_saya_app.php";
  static const fetchProfilePictureUrl = "https://bedbug-tidy-halibut.ngrok-free.app/WICARA_FIX/Wicara_User_Web/backend/profile/";
}