import 'package:apk_agenda_contatos/database/helper/contact_helper.dart';
import 'package:apk_agenda_contatos/database/model/contact_model.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:apk_agenda_contatos/service/apk_agenda_service.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact? _editContact;
  bool _userEdited = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imgController = TextEditingController();
  final ContactHelper _helper = ContactHelper();
  final ImagePicker _picker = ImagePicker();
  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final InvertextoApiService _api = InvertextoApiService();
  final cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  String? _emailError;
  String? _cepError;
  bool _loadingCep = false;

  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editContact = Contact(name: "", email: "", phone: "", img: null);
    } else {
      _editContact = widget.contact;
      _nameController.text = _editContact?.name ?? '';
      _emailController.text = _editContact?.email ?? '';
      _phoneController.text = _editContact?.phone ?? '';
      _imgController.text = _editContact?.img ?? '';
      _cepController.text = cepMask.maskText(_editContact?.cep ?? '');
      _logradouroController.text = _editContact?.logradouro ?? '';
      _numeroController.text = _editContact?.numero ?? '';
      _complementoController.text = _editContact?.complemento ?? '';
      _bairroController.text = _editContact?.bairro ?? '';
      _cidadeController.text = _editContact?.cidade ?? '';
      _ufController.text = _editContact?.uf ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _imgController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(_editContact?.name ?? "Novo contato"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveContact();
        },
        child: const Icon(Icons.save),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => _selectImage(),
              child: Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image:
                        _editContact?.img != null &&
                            _editContact!.img!.isNotEmpty
                        ? FileImage(File(_editContact!.img!))
                        : AssetImage("assets/imgs/avatar.png") as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nome"),
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editContact?.name = text;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                errorText: _emailError,
              ),
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editContact?.email = text;
                  _emailError = null;
                });
              },
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                LowerCaseFormatter(),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Telefone"),
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editContact?.phone = text;
                });
              },
              keyboardType: TextInputType.phone,
              inputFormatters: [phoneMask],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cepController,
              decoration: InputDecoration(
                labelText: "CEP",
                errorText: _cepError,
                suffixIcon: _loadingCep
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _buscarCep,
                      ),
              ),
              onChanged: (text) {
                _userEdited = true;
                _editContact?.cep = text;
                setState(() => _cepError = null);
                if (text.length == 9) _buscarCep();
              },
              keyboardType: TextInputType.number,
              inputFormatters: [cepMask],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _logradouroController,
              decoration: const InputDecoration(labelText: "Logradouro"),
              onChanged: (text) {
                _userEdited = true;
                _editContact?.logradouro = text;
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _numeroController,
              decoration: const InputDecoration(labelText: "Número"),
              onChanged: (text) {
                _userEdited = true;
                _editContact?.numero = text;
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _complementoController,
              decoration: const InputDecoration(labelText: "Complemento"),
              onChanged: (text) {
                _userEdited = true;
                _editContact?.complemento = text;
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bairroController,
              decoration: const InputDecoration(labelText: "Bairro"),
              onChanged: (text) {
                _userEdited = true;
                _editContact?.bairro = text;
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cidadeController,
              decoration: const InputDecoration(labelText: "Cidade"),
              onChanged: (text) {
                _userEdited = true;
                _editContact?.cidade = text;
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ufController,
              decoration: const InputDecoration(labelText: "UF"),
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
              onChanged: (text) {
                _userEdited = true;
                _editContact?.uf = text;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    final erro = Validador.cep(cep);
    if (erro != null) {
      setState(() => _cepError = erro);
      return;
    }

    setState(() {
      _loadingCep = true;
      _cepError = null;
    });
    try {
      final data = await _api.buscaCEP(cep);
      if (!mounted) return;
      setState(() {
        _logradouroController.text = _editContact!.logradouro =
            (data['street'] ?? '').toString();
        _bairroController.text = _editContact!.bairro =
            (data['neighborhood'] ?? '').toString();
        _cidadeController.text = _editContact!.cidade = (data['city'] ?? '')
            .toString();
        _ufController.text = _editContact!.uf = (data['state'] ?? '')
            .toString();
        _complementoController.text = _editContact!.complemento =
            (data['complement'] ?? '').toString();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cepError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingCep = false);
    }
  }

  Future<void> _selectImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Tirar foto"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Escolher da galeria"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (image == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(
      dir.path,
      'contact_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}',
    );
    await image.saveTo(path);

    if (!mounted) return;
    setState(() {
      _userEdited = true;
      _editContact?.img = path;
    });
  }

  Future<void> _saveContact() async {
    if (_editContact!.name.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nome é obrigatório!")));
      return;
    }

    final erroEmail = Validador.email(_editContact!.email);
    if (erroEmail != null) {
      setState(() => _emailError = erroEmail);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(erroEmail)));
      return;
    }

    try {
      if (_editContact?.id != null) {
        await _helper.updateContact(_editContact!);
      } else {
        await _helper.saveContact(_editContact!);
      }
    } catch (e) {
      debugPrint("Erro ao salvar: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e")));
      return;
    }

    if (!mounted) return;
    Navigator.pop(context, _editContact);
  }
}

class LowerCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}
