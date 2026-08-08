import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/app_toast.dart';
import '../controllers/personal_notifier.dart';
import '../../domain/models/personal_element_with_items.dart';

class PersonalSpaceScreen extends StatefulWidget {
  const PersonalSpaceScreen({super.key});

  @override
  State<PersonalSpaceScreen> createState() => _PersonalSpaceScreenState();
}

class _PersonalSpaceScreenState extends State<PersonalSpaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final notifier = context.read<PersonalNotifier>();
        switch (_tabController.index) {
          case 0:
            notifier.setFilterTipo(TipoElementoPersonal.nota);
            break;
          case 1:
            notifier.setFilterTipo(TipoElementoPersonal.lista);
            break;
          case 2:
            notifier.setFilterTipo(TipoElementoPersonal.meta);
            break;
        }
      }
    });

    // Pestaña inicial por defecto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalNotifier>().setFilterTipo(TipoElementoPersonal.nota);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PersonalNotifier>();
    final items = notifier.elementosFiltrados;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Espacio Personal'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          indicatorColor: const Color(0xFF6366F1),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.note_alt_rounded, size: 20), text: 'Notas & Datos'),
            Tab(icon: Icon(Icons.checklist_rounded, size: 20), text: 'Listas'),
            Tab(icon: Icon(Icons.flag_rounded, size: 20), text: 'Metas'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // BÚSQUEDA GLOBAL
            Container(
              color: theme.cardColor,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => notifier.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Buscar notas, datos, listas o metas...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            notifier.setSearchQuery('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9), // Slate 100
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // LISTA DE ELEMENTOS
            Expanded(
              child: notifier.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            switch (item.elemento.tipo) {
                              case TipoElementoPersonal.nota:
                                return _buildNotaCard(context, item, notifier);
                              case TipoElementoPersonal.lista:
                                return _buildListaCard(context, item, notifier);
                              case TipoElementoPersonal.meta:
                                return _buildMetaCard(context, item, notifier);
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarModalCreacionContextual(context, notifier),
        backgroundColor: const Color(0xFF0F172A),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.folder_open_rounded, size: 56, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text(
              'No hay elementos',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              'Agrega tu primera nota, lista de compras u objetivo personal.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // --- TARJETA DE NOTA / DATO FRECUENTE ---
  Widget _buildNotaCard(BuildContext context, ElementoPersonalConItems item, PersonalNotifier notifier) {
    final el = item.elemento;
    final esFijado = el.esFijado;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esFijado ? const Color(0xFF818CF8) : const Color(0xFFE2E8F0),
          width: esFijado ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPrioridadBadge(el.prioridad),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    el.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    esFijado ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: esFijado ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: () => notifier.toggleFijado(el),
                ),
              ],
            ),
            if (el.contenido != null && el.contenido!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Text(
                  el.contenido!,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cat: ${el.categoria}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    if (el.contenido != null && el.contenido!.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: el.contenido!));
                          AppToast.show(context, message: 'Copiado al portapapeles!');
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF4F46E5)),
                        label: const Text('Copiar', style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                      onPressed: () => _confirmarEliminacion(context, notifier, el.id),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TARJETA DE LISTA / CHECKLIST ---
  Widget _buildListaCard(BuildContext context, ElementoPersonalConItems item, PersonalNotifier notifier) {
    final el = item.elemento;
    final items = item.items;
    final completados = items.where((i) => i.completado).length;
    final total = items.length;
    final pct = total > 0 ? (completados / total) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            _buildPrioridadBadge(el.prioridad),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                el.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: const Color(0xFF10B981), // Emerald
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$completados/$total',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          ...items.map((subItem) {
            return ListTile(
              dense: true,
              leading: Checkbox(
                value: subItem.completado,
                activeColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (_) => notifier.toggleItemLista(subItem.id, subItem.completado),
              ),
              title: Text(
                subItem.texto,
                style: TextStyle(
                  fontSize: 14,
                  decoration: subItem.completado ? TextDecoration.lineThrough : null,
                  color: subItem.completado ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF4F46E5), size: 20),
                  onPressed: () => _mostrarModalLista(context, notifier, itemExistente: item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                  onPressed: () => _confirmarEliminacion(context, notifier, el.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TARJETA DE META / OBJETIVO ---
  Widget _buildMetaCard(BuildContext context, ElementoPersonalConItems item, PersonalNotifier notifier) {
    final el = item.elemento;
    final actual = el.progresoActual ?? 0;
    final total = el.progresoTotal ?? 1;
    final pct = (actual / total).clamp(0.0, 1.0);

    String progresoTemporalStr = '';
    if (el.fechaObjetivo != null) {
      final ahora = DateTime.now();
      final diffTotal = el.fechaObjetivo!.difference(el.fechaCreacion).inDays;
      final diffPasado = ahora.difference(el.fechaCreacion).inDays;
      if (diffTotal > 0) {
        final pctTiempo = ((diffPasado / diffTotal) * 100).clamp(0, 100).toInt();
        final diasRestantes = el.fechaObjetivo!.difference(ahora).inDays;
        progresoTemporalStr = 'Tiempo: $pctTiempo% ($diasRestantes días restantes)';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPrioridadBadge(el.prioridad),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    el.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
            if (el.contenido != null && el.contenido!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                el.contenido!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: const Color(0xFFE2E8F0),
                color: const Color(0xFF6366F1), // Indigo
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso: $actual de $total (${(pct * 100).toInt()}%)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFF64748B)),
                      onPressed: () => notifier.decrementarProgresoMeta(el),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF6366F1)),
                      onPressed: () => notifier.incrementarProgresoMeta(el),
                    ),
                  ],
                ),
              ],
            ),
            if (progresoTemporalStr.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    progresoTemporalStr,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                  onPressed: () => _confirmarEliminacion(context, notifier, el.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioridadBadge(Prioridad p) {
    Color bg = const Color(0xFFF1F5F9);
    Color txt = const Color(0xFF64748B);
    String label = 'Baja';

    switch (p) {
      case Prioridad.alta:
        bg = const Color(0xFFFEE2E2);
        txt = const Color(0xFFEF4444);
        label = 'Alta';
        break;
      case Prioridad.media:
        bg = const Color(0xFFFEF3C7);
        txt = const Color(0xFFD97706);
        label = 'Media';
        break;
      case Prioridad.baja:
        bg = const Color(0xFFF1F5F9);
        txt = const Color(0xFF64748B);
        label = 'Baja';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: txt),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, PersonalNotifier notifier, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Elemento'),
        content: const Text('¿Deseas eliminar este elemento permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await notifier.eliminarElemento(id);
    }
  }

  void _mostrarModalCreacionContextual(BuildContext context, PersonalNotifier notifier) {
    final cardBg = AppColors.cardBackground(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Qué deseas crear?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEEF2FF),
                    child: Icon(Icons.note_alt_rounded, color: Color(0xFF4F46E5)),
                  ),
                  title: Text('Nota / Dato Frecuente', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
                  subtitle: Text('Alias, CBU, credenciales, enlaces o notas rápidas', style: TextStyle(color: textSecondary)),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarModalNota(context, notifier);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFECFDF5),
                    child: Icon(Icons.checklist_rounded, color: Color(0xFF10B981)),
                  ),
                  title: Text('Lista / Checklist', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
                  subtitle: Text('Supermercado, equipaje o to-dos sin fecha', style: TextStyle(color: textSecondary)),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarModalLista(context, notifier);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEEF2FF),
                    child: Icon(Icons.flag_rounded, color: Color(0xFF6366F1)),
                  ),
                  title: Text('Meta / Objetivo', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
                  subtitle: Text('Objetivos con indicador de progreso y plazo', style: TextStyle(color: textSecondary)),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarModalMeta(context, notifier);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // MODAL NOTA
  void _mostrarModalNota(BuildContext context, PersonalNotifier notifier) {
    final tituloCtrl = TextEditingController();
    final contenidoCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'General');
    Prioridad prio = Prioridad.media;

    final cardBg = AppColors.cardBackground(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final isDark = AppColors.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Nueva Nota / Dato Frecuente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tituloCtrl,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Título (ej. CBU / Alias / Wi-Fi)',
                      labelStyle: TextStyle(color: textSecondary),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contenidoCtrl,
                    maxLines: 3,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Contenido / Texto a copiar',
                      labelStyle: TextStyle(color: textSecondary),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Prioridad>(
                    value: prio,
                    dropdownColor: cardBg,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Prioridad',
                      labelStyle: TextStyle(color: textSecondary),
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: Prioridad.alta, child: Text('Alta', style: TextStyle(color: textPrimary))),
                      DropdownMenuItem(value: Prioridad.media, child: Text('Media', style: TextStyle(color: textPrimary))),
                      DropdownMenuItem(value: Prioridad.baja, child: Text('Baja', style: TextStyle(color: textPrimary))),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => prio = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (tituloCtrl.text.trim().isNotEmpty) {
                        await notifier.guardarNotaODato(
                          titulo: tituloCtrl.text.trim(),
                          contenido: contenidoCtrl.text.trim(),
                          categoria: catCtrl.text.trim(),
                          prioridad: prio,
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Guardar Nota', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // MODAL LISTA
  void _mostrarModalLista(BuildContext context, PersonalNotifier notifier, {ElementoPersonalConItems? itemExistente}) {
    final tituloCtrl = TextEditingController(text: itemExistente?.elemento.titulo ?? '');
    final catCtrl = TextEditingController(text: itemExistente?.elemento.categoria ?? 'General');
    final itemCtrl = TextEditingController();
    List<String> itemsTemp = itemExistente?.items.map((i) => i.texto).toList() ?? [];
    Prioridad prio = itemExistente?.elemento.prioridad ?? Prioridad.media;

    final cardBg = AppColors.cardBackground(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      itemExistente == null ? 'Nueva Lista / Checklist' : 'Editar Lista',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tituloCtrl,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Título de la lista (ej: Compras)',
                        labelStyle: TextStyle(color: textSecondary),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: itemCtrl,
                            style: TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Agregar ítem',
                              labelStyle: TextStyle(color: textSecondary),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () {
                            if (itemCtrl.text.trim().isNotEmpty) {
                              setModalState(() {
                                itemsTemp.add(itemCtrl.text.trim());
                                itemCtrl.clear();
                              });
                            }
                          },
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemsTemp.length,
                        itemBuilder: (context, idx) {
                          return ListTile(
                            dense: true,
                            title: Text(itemsTemp[idx], style: TextStyle(color: textPrimary)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                              onPressed: () {
                                setModalState(() {
                                  itemsTemp.removeAt(idx);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (tituloCtrl.text.trim().isNotEmpty) {
                          await notifier.guardarLista(
                            idExistente: itemExistente?.elemento.id,
                            titulo: tituloCtrl.text.trim(),
                            categoria: catCtrl.text.trim(),
                            prioridad: prio,
                            itemsText: itemsTemp,
                          );
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Guardar Lista', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // MODAL META
  void _mostrarModalMeta(BuildContext context, PersonalNotifier notifier) {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final totalCtrl = TextEditingController(text: '10');
    DateTime? fechaObj;
    Prioridad prio = Prioridad.media;

    final cardBg = AppColors.cardBackground(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Nueva Meta / Objetivo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tituloCtrl,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Título de la meta (ej. Leer libro)',
                      labelStyle: TextStyle(color: textSecondary),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Cantidad o Unidades totales',
                      labelStyle: TextStyle(color: textSecondary),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => fechaObj = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(
                      fechaObj == null
                          ? 'Seleccionar Fecha Límite Meta (Opcional)'
                          : 'Fecha Objetivo: ${fechaObj!.day}/${fechaObj!.month}/${fechaObj!.year}',
                      style: TextStyle(color: textPrimary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (tituloCtrl.text.trim().isNotEmpty) {
                        final total = int.tryParse(totalCtrl.text.trim()) ?? 1;
                        await notifier.guardarMeta(
                          titulo: tituloCtrl.text.trim(),
                          descripcion: descCtrl.text.trim(),
                          categoria: 'General',
                          prioridad: prio,
                          progresoTotal: total,
                          fechaObjetivo: fechaObj,
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Guardar Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}
