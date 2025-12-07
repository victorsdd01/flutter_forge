import 'dart:io';

void main() async {
  print('🔄 Regenerating templates...');
  final result = await Process.run(
    'dart',
    ['scripts/generate_template_contents.dart'],
    runInShell: true,
  );
  
  print(result.stdout);
  if (result.stderr.toString().isNotEmpty) {
    print(result.stderr);
  }
  
  if (result.exitCode == 0) {
    print('✅ Templates regenerated successfully!');
  } else {
    print('❌ Error regenerating templates');
    exit(1);
  }
}

