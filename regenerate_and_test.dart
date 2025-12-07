import 'dart:io';
import 'dart:async';

Future<void> main() async {
  print('🔄 Step 1: Regenerating templates...');
  
  final regenerateProcess = await Process.start(
    'dart',
    ['scripts/generate_template_contents.dart'],
    mode: ProcessStartMode.normal,
  );
  
  await stdout.addStream(regenerateProcess.stdout);
  await stderr.addStream(regenerateProcess.stderr);
  
  final regenerateExitCode = await regenerateProcess.exitCode;
  
  if (regenerateExitCode != 0) {
    print('❌ Error regenerating templates');
    exit(1);
  }
  
  print('');
  print('✅ Templates regenerated successfully!');
  print('');
  print('🚀 Step 2: Generating test project...');
  print('');
  
  final generateProcess = await Process.start(
    'dart',
    ['generate_project.dart'],
    mode: ProcessStartMode.normal,
  );
  
  await stdout.addStream(generateProcess.stdout);
  await stderr.addStream(generateProcess.stderr);
  
  final generateExitCode = await generateProcess.exitCode;
  
  if (generateExitCode != 0) {
    print('❌ Error generating project');
    exit(1);
  }
  
  print('');
  print('✅ Project generated successfully!');
}

