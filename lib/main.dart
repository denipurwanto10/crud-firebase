import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Memastikan bahwa Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  // Menginisialisasi Firebase.
  await Firebase.initializeApp();
  // Menjalankan aplikasi Flutter.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Mahasiswa',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  //Sebuah field untuk memanggil ke Firebase Firestore
  // dengan nama 'datamhs'.
  final CollectionReference _datamhs =
  //mengakses 'datamhs' dari Firestore.
  FirebaseFirestore.instance.collection('datamhs');

  //fungsi untuk menghapus mahasiswa
  Future<void> _deleteMhs(String mhsid) async {
    //variable _datamhs untuk memanggil 'datamhs',
    //dan doc(mhsid) memberikan referensi ke mahasiswa
    //dengan ID yang dipilih, delete() digunakan untuk menghapus mahasiswa
    await _datamhs.doc(mhsid).delete();
    //menampilkan notifikasi delete
    _showSnackBar('Mahasiswa telah berhasil dihapus', Color(0xE6EE0000));
  }

  void _showSnackBar(String note, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(note),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          //judul aplikasi
          "Data Mahasiswa",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF101820),
      ),
      backgroundColor: const Color(0xFF101820),
      body: StreamBuilder(
        //Menggunakan stream dari firebase Firestore
        //menghasilkan Stream<QuerySnapshot>,
        //yang berisi data snapshot mahasiswa setiap kali ada perubahan.
        stream: _datamhs.snapshots(),
        //akan dipanggil setiap kali ada perubahan pada stream.
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              //Menentukan jumlah item dalam ListView,
              // diambil dari jumlah mahasiswa dalam snapshot dari firebase.
              itemCount: streamSnapshot.data!.docs.length,
              // dipanggil untuk setiap item dalam ListView
              itemBuilder: (context, index) {
                //representasi dari satu note dalam firebase Firestore.
                final DocumentSnapshot documentSnapshot =
                //Mengakses note ke-index dalam snapshot
                // terkini dari firebase.
                streamSnapshot.data!.docs[index];
                return Card(
                  color: Colors.yellow,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    //diambil dari data firebase Firestore dengan
                    // menggunakan key 'npm', 'nama', 'prodi', dan 'kelas'
                    // dari documentSnapshot.
                    title: Text(documentSnapshot['npm'].toString()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(documentSnapshot['nama']),
                        Text(documentSnapshot['prodi']),
                        Text(documentSnapshot['kelas']),
                      ],),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              color: const Color(0xE6562B13),
                              onPressed: () => createOrUpdate(
                                  documentSnapshot, context, _datamhs)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              color: const Color(0xE6EE0000),
                              onPressed: () =>
                                  _deleteMhs(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createOrUpdate(null, context, _datamhs),
        child: const Icon(Icons.add),
        backgroundColor: Colors.yellow,
      ),
    );
  }

  Future<void> createOrUpdate(DocumentSnapshot? docsnap, BuildContext ctx,
      CollectionReference? nts) async {
    //kontroler teks dibuat untuk mengontrol input.
    //Kontroler teks ini akan terhubung dengan field input pada textfield
    final TextEditingController npmController = TextEditingController();
    final TextEditingController namaController = TextEditingController();
    final TextEditingController prodiController = TextEditingController();
    final TextEditingController kelasController = TextEditingController();
    //jika variable docsnap tidak null maka nilai dari field
    //'npm', 'nama', 'prodi', dan 'kelas' pada dokumen tersebut diambil
    //dan diisikan ke dalam kontroler teks
    if (docsnap != null) {
      //variable diambil dari kolom yang
      //dibuat pada firebase firestore
      npmController.text = docsnap['npm'].toString();
      namaController.text = docsnap['nama'];
      prodiController.text = docsnap['prodi'];
      kelasController.text = docsnap['kelas'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: ctx,
        backgroundColor: Colors.yellow,
        builder: (BuildContext ctx) {
          return Padding(
            // agar keyboard tidak menutupi form input
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: npmController,
                  keyboardType: TextInputType.number, // Set keyboard type
                  decoration: const InputDecoration(labelText: 'NPM'),
                ),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                  ),
                ),
                TextField(
                  controller: prodiController,
                  decoration: const InputDecoration(
                    labelText: 'Prodi',
                  ),
                ),
                TextField(
                  controller: kelasController,
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color(0xFF101820),
                    ),),
                  child: Text(
                    //menampilkan teks 'Update' jika docsnap tidak null,
                    // dan 'Create' jika docsnap null.
                    (docsnap != null) ? 'Update' : 'Create',
                    style: const TextStyle(
                      color: Colors.white,
                    ),),
                  onPressed: () async {
                    final int npm = int.parse(npmController.text);
                    final String nama = namaController.text;
                    final String prodi = prodiController.text;
                    final String kelas = kelasController.text;
                    if (docsnap != null) {
                      // Update mahasiswa
                      await nts
                      //memanggil docsnap.id ketika mahasiswa sudah ada berdasarkan id
                          ?.doc(docsnap.id)
                          .update({"npm": npm, "nama": nama, "prodi": prodi, "kelas": kelas});
                      _showSnackBar('Mahasiswa berhasil diupdate', Color(0xE6562B13));
                    } else {
                      // Add mahasiswa
                      await nts?.add({"npm": npm, "nama": nama, "prodi": prodi, "kelas": kelas});
                      _showSnackBar('Mahasiswa berhasil ditambahkan', Color(0xE600EF0C));}
                    //mereset teks controller ketika selesai melakukan aksi
                    //dan menutup form
                    npmController.text = '';
                    namaController.text = '';
                    prodiController.text = '';
                    kelasController.text = '';
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ),
          );
        });
  }
}
