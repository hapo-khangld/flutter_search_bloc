import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../states/blocs/searcher_bloc/searcher_bloc.dart';
import '../../states/blocs/searcher_preview_bloc/searcher_preview_bloc.dart';
import '../../states/provider/searcher_app_state.dart';
import '../searcher_bar_preview/searcher_bar_preview.dart';
import 'local_widgets/animated_waves.dart';
import 'local_widgets/group_chip.dart';
import 'local_widgets/searcher_buttons.dart';

class SearcherBar extends StatefulWidget {
  const SearcherBar({
    Key? key,
  }) : super(key: key);

  @override
  _SearcherBarState createState() => _SearcherBarState();
}

class _SearcherBarState extends State<SearcherBar> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _searchBarFocusNode = FocusNode();

  @override
  void dispose() {
    _searchBarFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850, minWidth: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<SearcherAppState>(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 12,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          GroupChip(selected: false),
                        ],
                      ),
                    ),
                  ),
                ),
                builder: (context, state, child) {
                  return Material(
                    elevation: 15.0,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(25.0),
                    child: SizedBox(
                      height: 65,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedWaves(incognito: state.incognito),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                color: state.incognito
                                    ? Colors.grey[800]!.withOpacity(0.64)
                                    : Colors.grey[400]!.withOpacity(0.64),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 8.0),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: SearcherBarKeyboardListener(
                                              child: BlocListener<SearcherBloc,
                                                  SearcherState>(
                                                bloc: state.searcherBloc,
                                                listener: (context, state) {
                                                  if (state
                                                      is SearcherSuggestionsClear) {
                                                    _textEditingController
                                                        .clear();
                                                    _searchBarFocusNode
                                                        .requestFocus();
                                                  }
                                                },
                                                child: TextField(
                                                  controller:
                                                      _textEditingController,
                                                  autofocus: true,
                                                  focusNode:
                                                      _searchBarFocusNode,
                                                  textAlignVertical:
                                                      TextAlignVertical.center,
                                                  style: TextStyle(
                                                      color: state.incognito
                                                          ? Colors.grey[200]
                                                          : Colors.black),
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: 'Search...',
                                                    hintStyle: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  ),
                                                  onSubmitted: (query) =>
                                                      state.run(query),
                                                  onChanged: (query) => state
                                                      .getSuggestions(query),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SearcherButtons(
                                            initialSearcherMode:
                                                state.currentSearcherMode,
                                            clear: () => state.searcherBloc
                                                .add(const ClearSuggestions()),
                                            submit: () => state.run(
                                                _textEditingController.text),
                                          ),
                                        ],
                                      ),
                                    ),
                                    child!,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            const SearcherBarPreview()
          ],
        ),
      ),
    );
  }
}

// Code from:
// https://github.com/flutter/flutter/issues/75675#issuecomment-831581709.
class SearcherBarKeyboardListener extends StatefulWidget {
  const SearcherBarKeyboardListener({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _SearcherBarKeyboardListenerState();
}

class _SearcherBarKeyboardListenerState
    extends State<SearcherBarKeyboardListener> {
  final FocusNode focus =
      FocusNode(skipTraversal: true, canRequestFocus: false);

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focus,
      onKey: (_, RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (Provider.of<SearcherAppState>(context, listen: false)
                .searcherBloc
                .state is SearcherSuggestionsDone) {
              focus.nextFocus();
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (event.isAltPressed) {
              Provider.of<SearcherAppState>(context, listen: false)
                  .previewBloc
                  .add(PreviousPreview());
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (event.isAltPressed) {
              Provider.of<SearcherAppState>(context, listen: false)
                  .previewBloc
                  .add(NextPreview());
            }
          } else if (event.logicalKey == LogicalKeyboardKey.keyQ) {
            if (event.isAltPressed) {
              Provider.of<SearcherAppState>(context, listen: false)
                  .previewBloc
                  .add(const CloseCurrentPreview());
            }
          }
        }
        return event.physicalKey == PhysicalKeyboardKey.shiftRight
            ? KeyEventResult.handled
            : KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
