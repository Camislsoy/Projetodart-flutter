import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AppFrases());
}

/// Aplicativo principal com tema delicado (lilás/roxo/rosa)
class AppFrases extends StatefulWidget {
  const AppFrases({super.key});

  @override
  State<AppFrases> createState() => _AppFrasesEstado();
}

class _AppFrasesEstado extends State<AppFrases> {
  // Você pode alternar o tema claro/escuro clicando no ícone do AppBar
  ThemeMode modoTema = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frases do Dia',
      // Tema claro com semente lilás
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF9C6BFF), // lilás suave
        brightness: Brightness.light,
      ),
      // Tema escuro com semente lilás clarinho
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFD68BFF), // lilás claro no modo escuro
        brightness: Brightness.dark,
      ),
      themeMode: modoTema,
      home: TelaInicial(
        ehEscuro: modoTema == ThemeMode.dark,
        alternarTema: () {
          setState(() {
            modoTema = (modoTema == ThemeMode.dark)
                ? ThemeMode.light
                : ThemeMode.dark;
          });
        },
      ),
    );
  }
}

/// Tela principal: mostra a frase atual e botões de ação
class TelaInicial extends StatefulWidget {
  final bool ehEscuro;
  final VoidCallback alternarTema;

  const TelaInicial({
    super.key,
    required this.ehEscuro,
    required this.alternarTema,
  });

  @override
  State<TelaInicial> createState() => _TelaInicialEstado();
}

class _TelaInicialEstado extends State<TelaInicial> {
  final geradorAleatorio = Random();

  /// Lista de frases (pode personalizar depois!)
  final List<String> frases = const [
    'Você é capaz de mais do que imagina.',
    'Cuide de você com carinho todos os dias.',
    'Passo a passo, sem pressa e com amor.',
    'Sua constância é mais forte que a dúvida.',
    'Permita-se recomeçar sempre que precisar.',
    'Feito com calma também é feito com força.',
    'Confie no processo e celebre os detalhes.',
    'Disciplina é um abraço no futuro.',
    'Respire fundo: você chegou até aqui.',
    'Gentileza com você é progresso real.',
  ];

  /// Índice da frase sendo exibida agora
  late int indiceAtual;

  /// Conjunto com os índices favoritados (ex.: {0, 3, 7})
  Set<int> favoritos = {};

  @override
  void initState() {
    super.initState();
    indiceAtual = geradorAleatorio.nextInt(frases.length);
    _carregarFavoritos();
  }

  /// Carrega os favoritos salvos no aparelho (SharedPreferences)
  Future<void> _carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList('favoritos') ?? [];
    setState(() {
      favoritos = lista.map(int.parse).toSet();
    });
  }

  /// Salva os favoritos no aparelho
  Future<void> _salvarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoritos',
      favoritos.map((i) => i.toString()).toList(),
    );
  }

  /// Sorteia uma nova frase (evita repetir a mesma imediatamente)
  void _novaFrase() {
    int novo;
    do {
      novo = geradorAleatorio.nextInt(frases.length);
    } while (novo == indiceAtual && frases.length > 1);

    setState(() => indiceAtual = novo);
  }

  /// Marca/desmarca a frase atual como favorita
  Future<void> _alternarFavorito() async {
    setState(() {
      if (favoritos.contains(indiceAtual)) {
        favoritos.remove(indiceAtual);
      } else {
        favoritos.add(indiceAtual);
      }
    });
    await _salvarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    final frase = frases[indiceAtual];
    final ehFavorita = favoritos.contains(indiceAtual);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frases do Dia'),
        actions: [
          // Botão: alternar tema claro/escuro
          IconButton(
            tooltip: 'Trocar tema',
            onPressed: widget.alternarTema,
            icon: Icon(widget.ehEscuro ? Icons.light_mode : Icons.dark_mode),
          ),
          // Botão: ir para a tela de favoritos
          IconButton(
            tooltip: 'Favoritos',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TelaFavoritos(
                    frases: frases,
                    favoritosIniciais: favoritos,
                    aoAlterar: (novoConjunto) async {
                      setState(() => favoritos = novoConjunto);
                      await _salvarFavoritos();
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),

      // FUNDO COM DEGRADÊ LILÁS/ROSA 💜🌸
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE9D6FF), // lilás bem clarinho
              Color(0xFFF9D6FF), // rosinha suave
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cartão da frase com leve transparência e sombra rosada
                  Card(
                    elevation: 6,
                    color: Colors.white.withOpacity(0.90),
                    shadowColor: Colors.pinkAccent.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 28,
                      ),
                      child: Text(
                        '"$frase"',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF7A3EB1), // lilás elegante
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botões
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: _novaFrase,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Nova frase'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _alternarFavorito,
                        icon: Icon(
                          ehFavorita ? Icons.favorite : Icons.favorite_border,
                          color: Colors.pinkAccent,
                        ),
                        label: Text(
                          ehFavorita ? 'Remover' : 'Favoritar',
                          style: const TextStyle(color: Colors.pinkAccent),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.pinkAccent),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tela de favoritos: lista e permite remover
class TelaFavoritos extends StatefulWidget {
  final List<String> frases;
  final Set<int> favoritosIniciais;
  final Future<void> Function(Set<int>) aoAlterar;

  const TelaFavoritos({
    super.key,
    required this.frases,
    required this.favoritosIniciais,
    required this.aoAlterar,
  });

  @override
  State<TelaFavoritos> createState() => _TelaFavoritosEstado();
}

class _TelaFavoritosEstado extends State<TelaFavoritos> {
  late Set<int> favoritosLocais;

  @override
  void initState() {
    super.initState();
    favoritosLocais = {...widget.favoritosIniciais};
  }

  @override
  Widget build(BuildContext context) {
    final itens = favoritosLocais.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus favoritos')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE9D6FF),
              Color(0xFFF9D6FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: itens.isEmpty
            ? const Center(
                child: Text(
                  'Nenhuma frase favoritada ainda.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: itens.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final idx = itens[i];
                  return Dismissible(
                    key: ValueKey(idx),
                    background: Container(
                      color: Colors.pinkAccent.withOpacity(0.20),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16),
                      child: const Icon(Icons.delete, color: Colors.pinkAccent),
                    ),
                    secondaryBackground: Container(
                      color: Colors.pinkAccent.withOpacity(0.20),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.pinkAccent),
                    ),
                    onDismissed: (_) {
                      setState(() => favoritosLocais.remove(idx));
                      widget.aoAlterar(favoritosLocais);
                    },
                    child: Card(
                      color: Colors.white.withOpacity(0.92),
                      child: ListTile(
                        title: Text(
                          widget.frases[idx],
                          style: const TextStyle(
                            color: Color(0xFF7A3EB1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Remover',
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.pinkAccent),
                          onPressed: () {
                            setState(() => favoritosLocais.remove(idx));
                            widget.aoAlterar(favoritosLocais);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
