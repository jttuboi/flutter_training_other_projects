import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_list/posts/posts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakePostState extends Fake implements PostState {}

class FakePostEvent extends Fake implements PostEvent {}

class MockPostBloc extends MockBloc<PostEvent, PostState> implements PostBloc {}

extension on WidgetTester {
  Future<void> pumpPostsList(PostBloc postBloc) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: postBloc,
          child: const PostsList(),
        ),
      ),
    );
  }
}

void main() {
  final mockPosts = List.generate(5, (i) => Post(id: i, title: 'a $i', body: 'qwe $i'));

  late PostBloc postBloc;

  setUpAll(() {
    registerFallbackValue<PostState>(FakePostState());
    registerFallbackValue<PostEvent>(FakePostEvent());
  });

  setUp(() {
    postBloc = MockPostBloc();
  });

  group('PostsList', () {
    testWidgets('renders CircularProgressIndicator when post status is initial', (tester) async {
      when(() => postBloc.state).thenReturn(const PostState());
      await tester.pumpPostsList(postBloc);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders no posts text when post status is success but with 0 posts', (tester) async {
      when(() => postBloc.state).thenReturn(const PostState(
        status: PostStatus.success,
        posts: [],
        hasReachedMax: true,
      ));
      await tester.pumpPostsList(postBloc);

      expect(find.text('no posts'), findsOneWidget);
    });

    testWidgets('renders 5 posts and a bottom loader when post max is not reached yet', (tester) async {
      when(() => postBloc.state).thenReturn(PostState(
        status: PostStatus.success,
        posts: mockPosts,
      ));
      await tester.pumpPostsList(postBloc);

      expect(find.byType(PostListItem), findsNWidgets(5));
      expect(find.byType(BottomLoader), findsOneWidget);
    });

    testWidgets('does not render bottom loader when post max is reached', (tester) async {
      when(() => postBloc.state).thenReturn(PostState(
        status: PostStatus.success,
        posts: mockPosts,
        hasReachedMax: true,
      ));
      await tester.pumpPostsList(postBloc);

      expect(find.byType(BottomLoader), findsNothing);
    });

    testWidgets('fetches more posts when scrolled to the bottom', (tester) async {
      when(() => postBloc.state).thenReturn(PostState(
        status: PostStatus.success,
        posts: List.generate(10, (i) => Post(id: i, title: 'post title', body: 'post body')),
      ));
      await tester.pumpPostsList(postBloc);
      // simula o scroll da lista do meio (default) para cima
      await tester.drag(find.byType(PostsList), const Offset(0, -500));

      // deve adicionar o evento PostFetched() quando passa de 90%
      verify(() => postBloc.add(PostFetched())).called(1);
    });
  });
}
