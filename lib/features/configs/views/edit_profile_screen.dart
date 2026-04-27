import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/common_models/user_profile.dart';
import 'package:plus_vocab/core/services/storage_service.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/auth/controllers/auth_controller.dart';
import 'package:plus_vocab/features/user/models/user_service.dart';
import 'package:provider/provider.dart';

const List<(String apiValue, String labelPt)> _fluencyChoices = [
  ('beginner', 'Iniciante'),
  ('intermediate', 'Intermediário'),
  ('advanced', 'Avançado'),
];

String _capitalizeWords(String value) {
  return value
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .map(
        (s) =>
            s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}' : '',
      )
      .where((s) => s.isNotEmpty)
      .join(' ');
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _ageController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  String _email = '';
  String _headerName = '';

  String _fluencyApi = 'intermediate';
  bool _mostrarProximasPalavras = true;

  int _initialAge = 20;
  String _initialName = '';
  String _initialArea = '';
  String _initialFluency = 'intermediate';
  bool _initialMostrarProximas = true;

  String? _userId;

  String get _tituloCabecalho {
    final digitado = _nameController.text.trim();
    if (digitado.isNotEmpty) return _capitalizeWords(digitado);
    return _headerName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _loading = false;
        _loadError = 'Sessão inválida. Faça login novamente.';
      });
      return;
    }
    _userId = userId;

    final storage = context.read<StorageService>();
    final userService = context.read<UserService>();
    final mostrar = await storage.getMostrarProximasPalavras();

    setState(() {
      _mostrarProximasPalavras = mostrar;
      _initialMostrarProximas = mostrar;
    });

    try {
      final payload = await userService.fetchUserById(userId);
      final profile = payload.profile ??
          const UserProfile(
            name: '',
            age: 20,
            fluency: 'intermediate',
            occupationArea: '',
            locale: 'pt-BR',
          );

      final fluencyNorm = _normalizarFluency(profile.fluency);

      if (!mounted) return;
      setState(() {
        _email = payload.email;
        _headerName = profile.name.trim().isNotEmpty
            ? _capitalizeWords(profile.name.trim())
            : _email;
        _nameController.text = profile.name;
        _areaController.text = profile.occupationArea;
        _ageController.text = profile.age > 0 ? '${profile.age}' : '';
        _fluencyApi = fluencyNorm;
        _initialAge = profile.age;
        _initialName = profile.name;
        _initialArea = profile.occupationArea;
        _initialFluency = fluencyNorm;
        _loading = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  String _normalizarFluency(String value) {
    final v = value.trim().toLowerCase();
    for (final e in _fluencyChoices) {
      if (e.$1 == v) return e.$1;
    }
    return 'intermediate';
  }

  Map<String, dynamic> _montarBodyParcial() {
    final name = _nameController.text.trim();
    final area = _areaController.text.trim();
    final idadeDigitada = int.tryParse(_ageController.text.trim());

    final body = <String, dynamic>{};
    if (name != _initialName.trim()) body['name'] = name;
    if (area != _initialArea.trim()) body['occupationArea'] = area;
    if (idadeDigitada != null && idadeDigitada > 0 && idadeDigitada != _initialAge) {
      body['age'] = idadeDigitada;
    }
    if (_fluencyApi != _initialFluency) body['fluency'] = _fluencyApi;
    return body;
  }

  Future<void> _salvar() async {
    final userId = _userId;
    if (userId == null) return;

    final name = _nameController.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O nome deve ter pelo menos 2 caracteres.', style: GoogleFonts.lexend()),
        ),
      );
      return;
    }

    final idadeDigitada = int.tryParse(_ageController.text.trim());
    if (_ageController.text.trim().isNotEmpty &&
        (idadeDigitada == null || idadeDigitada <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informe uma idade válida (número inteiro maior que zero).', style: GoogleFonts.lexend()),
        ),
      );
      return;
    }
    if (_ageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informe sua idade.', style: GoogleFonts.lexend()),
        ),
      );
      return;
    }

    final storage = context.read<StorageService>();
    final userService = context.read<UserService>();
    final authController = context.read<AuthController>();
    final body = _montarBodyParcial();
    final toggleMudou = _mostrarProximasPalavras != _initialMostrarProximas;

    if (body.isNotEmpty) {
      setState(() => _saving = true);
      try {
        final atualizado = await userService.updateProfile(userId, body);
        await authController.updateCachedUserProfile(atualizado);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.lexend()),
            backgroundColor: AppColors.erro,
          ),
        );
        return;
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }

    await storage.setMostrarProximasPalavras(_mostrarProximasPalavras);
    if (!mounted) return;

    if (body.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil atualizado.', style: GoogleFonts.lexend())),
      );
    } else if (toggleMudou) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preferência salva.', style: GoogleFonts.lexend())),
      );
    }
    Navigator.of(context).pop(body.isNotEmpty || toggleMudou);
  }

  void _mostrarAjudaProximasPalavras() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mostrar próximas palavras', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
        content: Text(
          'Quando ativado, o app pode exibir sugestões de vocabulário relacionado durante a prática. '
          'A preferência fica salva neste aparelho.',
          style: GoogleFonts.lexend(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Entendi', style: GoogleFonts.lexend(color: AppColors.primaria)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.25),
            ),
          ),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaria))
                : _loadError != null
                    ? _buildErroCarregamento()
                    : _buildFormulario(),
          ),
          if (_saving)
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.textoPreto.withValues(alpha: 0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaria),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErroCarregamento() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _loadError = null;
              });
              _carregar();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaria),
            child: Text('Tentar novamente', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text('Voltar', style: GoogleFonts.lexend(color: AppColors.textoSecundario)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildAvatarENome(),
          const SizedBox(height: 28),
          _labeledField(
            label: 'Nome',
            child: _outlineField(
              controller: _nameController,
              hint: 'Seu nome',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 18),
          _labeledField(
            label: 'Área',
            child: _outlineField(
              controller: _areaController,
              hint: 'Área de atuação ou estudo',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  label: 'Idade',
                  child: _outlineField(
                    controller: _ageController,
                    hint: 'Ex.: 23',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _labeledField(
                  label: 'Fluência',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.branco,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.bordaCampo),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _fluencyApi,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textoSecundario),
                        style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoPreto),
                        items: _fluencyChoices
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e.$1,
                                child: Text(e.$2, style: GoogleFonts.lexend(fontSize: 13)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _fluencyApi = v);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Mostrar próximas palavras?',
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textoPreto,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.primaria.withValues(alpha: 0.85),
                      ),
                      onPressed: _mostrarAjudaProximasPalavras,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _mostrarProximasPalavras,
                onChanged: (v) => setState(() => _mostrarProximasPalavras = v),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                thumbColor: const WidgetStatePropertyAll<Color>(AppColors.branco),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primaria;
                  }
                  return null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _salvar,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaria,
                foregroundColor: AppColors.branco,
                disabledBackgroundColor: AppColors.primaria.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Salvar', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.erro,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-10, 0),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            color: AppColors.textoPreto,
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          ),
        ),
        Expanded(
          child: Text(
            'Editar dados de perfil',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textoPreto,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildAvatarENome() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.branco,
            border: Border.all(color: AppColors.primaria, width: 1.5),
          ),
          child: const Icon(Icons.person, color: AppColors.primaria, size: 44),
        ),
        const SizedBox(height: 14),
        Text(
          _tituloCabecalho,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaria,
          ),
        ),
        if (_email.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _email,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textoSecundario,
            ),
          ),
        ],
      ],
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textoSecundario,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _outlineField({
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    Widget? suffix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bordaCampo),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
