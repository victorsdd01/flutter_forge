import 'dart:io';

Future<void> main() async {
  print('🔄 Step 1: Regenerating templates...');
  print('');
  
  final regenerateResult = await Process.run(
    'dart',
    ['scripts/generate_template_contents.dart'],
    runInShell: true,
  );
  
  print(regenerateResult.stdout);
  if (regenerateResult.stderr.toString().isNotEmpty) {
    print(regenerateResult.stderr);
  }
  
  if (regenerateResult.exitCode != 0) {
    print('❌ Error regenerating templates');
    exit(1);
  }
  
  print('');
  print('✅ Templates regenerated successfully!');
  print('');
  print('🚀 Step 2: Generating project...');
  print('');
  
  final generateResult = await Process.run(
    'dart',
    ['generate_project.dart'],
    runInShell: true,
  );
  
  print(generateResult.stdout);
  if (generateResult.stderr.toString().isNotEmpty) {
    print(generateResult.stderr);
  }
  
  if (generateResult.exitCode != 0) {
    print('❌ Error generating project');
    exit(1);
  }
  
  print('');
  print('✅ All done!');
}

