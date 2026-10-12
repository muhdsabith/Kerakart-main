import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../data/shop_controller.dart';
import '../models/shop.dart';
import '../widgets/common.dart';
import 'product.dart';
import 'account.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  String category = 'All';
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(
        index: tab,
        children: [
          CatalogPage(
            category: category,
            onCategory: (v) => setState(() => category = v),
            onSaved: () => setState(() => tab = 2),
          ),
          CategoriesPage(
            onSelect: (v) => setState(() {
              category = v;
              tab = 0;
            }),
          ),
          CatalogPage(savedOnly: true, onBrowse: () => setState(() => tab = 0)),
          const AccountPage(),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: emerald,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24106B50),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 4; i++)
              if (i == tab)
                Flexible(
                  child: Align(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: navigationItem(i),
                  ),
                )
              else
                SizedBox(width: 48, child: navigationItem(i)),
          ],
        ),
      ),
    ),
  );
  Widget navigationItem(int index) {
    const labels = ['Home', 'Categories', 'Saved', 'Account'];
    const icons = [
      Icons.home_outlined,
      Icons.grid_view_rounded,
      Icons.favorite_border_rounded,
      Icons.person_outline_rounded,
    ];
    const selectedIcons = [
      Icons.home_rounded,
      Icons.grid_view_rounded,
      Icons.favorite_rounded,
      Icons.person_rounded,
    ];
    final selected = index == tab;
    return Semantics(
      selected: selected,
      button: true,
      label: labels[index],
      child: Tooltip(
        message: labels[index],
        child: Material(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => setState(() => tab = index),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 10 : 0,
                  vertical: 10,
                ),
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? selectedIcons[index] : icons[index],
                        color: selected ? emerald : const Color(0xFFD2E7DF),
                        size: 24,
                      ),
                      if (selected) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            labels[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: emerald,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class CatalogPage extends StatefulWidget {
  final bool savedOnly;
  final String category;
  final ValueChanged<String>? onCategory;
  final VoidCallback? onSaved, onBrowse;
  const CatalogPage({
    super.key,
    this.savedOnly = false,
    this.category = 'All',
    this.onCategory,
    this.onSaved,
    this.onBrowse,
  });
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final search = TextEditingController();
  String sort = 'Recommended';
  bool under500 = false;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> filters() async {
    var chosenSort = sort;
    var chosenPrice = under500;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Make it yours',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Sort By',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                              'Recommended',
                              'Price: low to high',
                              'Price: high to low',
                              'Top rated',
                            ]
                            .map(
                              (s) => ChoiceChip(
                                label: Text(s),
                                selected: s == chosenSort,
                                onSelected: (_) => update(() => chosenSort = s),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Under ₹500'),
                    value: chosenPrice,
                    onChanged: (v) => update(() => chosenPrice = v),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    'Show products',
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => update(() {
                        chosenSort = 'Recommended';
                        chosenPrice = false;
                      }),
                      child: const Text('Reset filters'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (applied == true && mounted) {
      setState(() {
        sort = chosenSort;
        under500 = chosenPrice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context).state;
    final found = products
        .where(
          (p) =>
              (!widget.savedOnly || state.saved.contains(p.id)) &&
              (widget.savedOnly ||
                  widget.category == 'All' ||
                  p.category == widget.category) &&
              ('${p.name} ${p.category} ${p.description}'
                  .toLowerCase()
                  .contains(search.text.toLowerCase().trim())) &&
              (!under500 || p.price < 500),
        )
        .toList();
    if (sort == 'Price: low to high') {
      found.sort((a, b) => a.price.compareTo(b.price));
    }
    if (sort == 'Price: high to low') {
      found.sort((a, b) => b.price.compareTo(a.price));
    }
    if (sort == 'Top rated') found.sort((a, b) => b.rating.compareTo(a.rating));
    return PageWidth(
      child: CustomScrollView(
        key: PageStorageKey(widget.savedOnly ? 'saved' : 'home'),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
              child: Row(
                children: [
                  if (!widget.savedOnly) ...[
                    const BrandMark(),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      widget.savedOnly ? 'Your favourites' : 'KeraBasket',
                      style: TextStyle(
                        fontSize: widget.savedOnly ? 27 : 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.9,
                      ),
                    ),
                  ),
                  if (!widget.savedOnly)
                    IconButton(
                      tooltip: 'Saved items',
                      onPressed: widget.onSaved,
                      icon: const Icon(Icons.favorite_border),
                    ),
                  const BagButton(),
                ],
              ),
            ),
          ),
          if (!widget.savedOnly)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 1, 20, 17),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: muted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        state.address.city.isEmpty
                            ? 'Deliver to Kerala'
                            : 'Deliver to ${state.address.city}',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: TextField(
                controller: search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: widget.savedOnly
                      ? 'Search your saved items'
                      : 'Search kurtas, bags, home decor…',
                  hintStyle: const TextStyle(fontSize: 13, color: muted),
                  prefixIcon: const Icon(Icons.search, color: muted),
                  suffixIcon: search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            search.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                ),
              ),
            ),
          ),
          if (!widget.savedOnly) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  runSpacing: 12,
                  children: ['All', 'Fashion', 'Home', 'Accessories']
                      .map(
                        (name) => Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () => widget.onCategory?.call(name),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: widget.category == name
                                            ? emerald
                                            : line,
                                        width: widget.category == name ? 2 : 1,
                                      ),
                                    ),
                                    child: name == 'All'
                                        ? CircleAvatar(
                                            backgroundColor:
                                                widget.category == name
                                                ? emerald
                                                : Colors.white,
                                            child: Text(
                                              'All',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: widget.category == name
                                                    ? Colors.white
                                                    : ink,
                                              ),
                                            ),
                                          )
                                        : ClipOval(
                                            child: ProductPhoto(
                                              name == 'Fashion' ? 0 : name == 'Home' ? 2 : 4,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.category == name
                                          ? emerald
                                          : muted,
                                      fontWeight: widget.category == name
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            if (search.text.isEmpty && widget.category == 'All')
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 23, 20, 20),
                  child: _HeroBanner(
                    onTap: () => widget.onCategory?.call('Home'),
                  ),
                ),
              ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.savedOnly
                          ? '${found.length} saved pieces'
                          : search.text.isNotEmpty
                          ? 'Search results'
                          : widget.category == 'All'
                          ? 'Picked For You'
                          : '${widget.category} essentials',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: line),
                      foregroundColor: ink,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: filters,
                    icon: const Icon(Icons.tune, size: 16),
                    label: Text(
                      under500 || sort != 'Recommended'
                          ? 'Filters •'
                          : 'Filters',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (found.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(
                icon: widget.savedOnly
                    ? Icons.favorite_border
                    : Icons.search_off,
                title: widget.savedOnly && state.saved.isEmpty
                    ? 'Keep what you love'
                    : 'No pieces found',
                subtitle: widget.savedOnly && state.saved.isEmpty
                    ? 'Tap a heart to save a little inspiration.'
                    : 'Try another search or reset your filters.',
                action: widget.savedOnly && state.saved.isEmpty
                    ? 'Explore the collection'
                    : 'Reset search',
                onAction: widget.savedOnly && state.saved.isEmpty
                    ? widget.onBrowse
                    : () {
                        search.clear();
                        setState(() {
                          sort = 'Recommended';
                          under500 = false;
                        });
                        widget.onCategory?.call('All');
                      },
              ),
            ),
          if (found.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.crossAxisExtent >= 800
                      ? 4
                      : constraints.crossAxisExtent >= 600
                      ? 3
                      : 2;
                  return SliverList.separated(
                    itemCount: (found.length / cols).ceil(),
                    separatorBuilder: (_, _) => const SizedBox(height: 18),
                    itemBuilder: (context, row) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var col = 0; col < cols; col++) ...[
                          if (col > 0) const SizedBox(width: 14),
                          Expanded(
                            child: row * cols + col < found.length
                                ? _ProductCard(found[row * cols + col])
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          if (found.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 26),
                child: Column(
                  children: [
                    Icon(Icons.spa_outlined, color: emerald, size: 25),
                    SizedBox(height: 8),
                    Text(
                      'Thoughtfully chosen. Everyday loved.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _HeroBanner({required this.onTap});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 252),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          const Positioned.fill(child: ProductPhoto(3, radius: 0)),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFEDE2D0),
                    Color(0xDDEDE2D0),
                    Color(0x00EDE2D0),
                  ],
                  stops: [0, .42, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(23),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'THE EVERYDAY EDIT',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: emerald,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Everyday,\nelevated.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 34,
                      height: 1.07,
                      letterSpacing: -.8,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Thoughtful pieces for\na brighter you.',
                    style: TextStyle(fontSize: 12, height: 1.4, color: ink),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 37),
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'Explore Collection',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard(this.product);
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => openPage(context, ProductPage(product: product)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1 / 1.1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProductPhoto(product.photo, label: product.name),
              Positioned(top: 3, right: 3, child: SaveButton(product)),
            ],
          ),
        ),
        const SizedBox(height: 9),
        Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          money(product.price),
          style: const TextStyle(
            fontSize: 21,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'M.R.P. ${money(product.originalPrice)}',
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: muted,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE5F1EB),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${product.discount}% off',
            style: const TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: emerald,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 15, color: emerald),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                '${product.rating} (${product.reviews})',
                style: const TextStyle(fontSize: 11, color: muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Row(
          children: [
            Icon(Icons.local_shipping_outlined, size: 13, color: muted),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                'Free Delivery',
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class CategoriesPage extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const CategoriesPage({super.key, required this.onSelect});
  @override
  Widget build(BuildContext context) => PageWidth(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Find your everyday',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w700,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'A few good things. Chosen with care.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 25),
        for (final category in ['Fashion', 'Home', 'Accessories'])
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: InkWell(
              onTap: () => onSelect(category),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 235,
                    width: double.infinity,
                    child: ProductPhoto(
                      category == 'Fashion' ? 0 : category == 'Home' ? 3 : 4,
                      radius: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 12, 2, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                category == 'Fashion'
                                    ? 'Easy silhouettes & everyday companions'
                                    : category == 'Home'
                                        ? 'Little rituals, beautiful spaces'
                                        : 'Smart essentials for your everyday',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: emerald),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
