import 'package:flutter_test/flutter_test.dart';
import 'package:withsave_frontend_test/view_model/post_editor_view_model.dart';

void main() {
  test('본문을 HTML로 저장했다가 되돌리면 그대로다', () {
    const text = 'a < b & "c"\n\n둘째 줄';
    expect(
      PostEditorViewModel.htmlToText(PostEditorViewModel.textToHtml(text)),
      text,
    );
  });

  test('다른 클라이언트의 단락 안 줄바꿈과 엔티티를 되돌린다', () {
    expect(
      PostEditorViewModel.htmlToText('<p>a<br>b&nbsp;&quot;c&quot; &#39;d&#39; &amp;lt;</p>'),
      'a\nb "c" \'d\' &lt;',
    );
  });
}
