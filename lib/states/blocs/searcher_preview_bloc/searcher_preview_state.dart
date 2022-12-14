part of 'searcher_preview_bloc.dart';

@immutable
abstract class SearcherPreviewState {
  final String title;
  final Widget preview;
  final bool single;
  final int globalID;

  const SearcherPreviewState({
    required this.title,
    required this.preview,
    this.single = true,
    required this.globalID,
  });

  int get instanceID => 0;
}

@immutable
abstract class PreviewStateNotifier extends SearcherPreviewState {
  final SearcherPreviewState previewState;

  PreviewStateNotifier({required this.previewState})
      : super(
            title: previewState.title,
            preview: previewState.preview,
            single: previewState.single,
            globalID: previewState.globalID);
}

@immutable
abstract class SearcherPreview extends SearcherPreviewState {
  final String title;
  final Widget preview;
  final bool single;
  static int globalPreviewCount = 0;
  late final int globalID;

  SearcherPreview({
    required this.title,
    required this.preview,
    this.single = true,
  }) : super(
            title: title,
            preview: preview,
            single: single,
            globalID: globalPreviewCount) {
    globalID = globalPreviewCount;
    globalPreviewCount++;
  }
}

class SearcherPreviewInitial extends AutocompletePreview {}

class AutocompletePreview extends SearcherPreview {
  AutocompletePreview()
      : super(title: 'Autocomplete', preview: const SearcherBarAutocomplete());
}

class NotesPreview extends SearcherPreview {
  NotesPreview() : super(title: 'Notes', preview: const SearcherNotesPreview());
}

class DummyPreview extends SearcherPreview {
  static final Random rnd = Random();
  static int dummyPreviewCount = 0;
  late final int _instanceID;

  DummyPreview()
      : super(
          title: 'Dummy Preview',
          preview: Container(
              color: Color.fromARGB(
            rnd.nextInt(256),
            rnd.nextInt(256),
            rnd.nextInt(256),
            rnd.nextInt(256),
          )),
          single: false,
        ) {
    _instanceID = dummyPreviewCount;
    dummyPreviewCount++;
  }

  @override
  int get instanceID => _instanceID;
}

class UpdatingPreview extends PreviewStateNotifier {
  @override
  final SearcherPreviewState previewState;
  final int from;
  final int to;

  UpdatingPreview({
    required this.previewState,
    required this.from,
    required this.to,
  }) : super(previewState: previewState);
}

class AddedPreview extends PreviewStateNotifier {
  @override
  final SearcherPreviewState previewState;
  final int to;

  AddedPreview({
    required this.previewState,
    required this.to,
  }) : super(previewState: previewState);
}

class RemovedPreview extends PreviewStateNotifier {
  @override
  final SearcherPreviewState previewState;
  final int from;

  RemovedPreview({
    required this.previewState,
    required this.from,
  }) : super(previewState: previewState);
}

class SwitchedCurrentPreview extends PreviewStateNotifier {
  final SearcherPreviewState previewState;
  final int newShown;

  SwitchedCurrentPreview({
    required this.previewState,
    required this.newShown,
  }) : super(previewState: previewState);
}
