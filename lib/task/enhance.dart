part of task;

void _enhance (List<String> files) {
  if (files.isEmpty) {
    print ('No files to enhance');
    return;
  }
  
  EntityEnhancer enhancer = new EntityEnhancer ();
  enhancer.enhance(_findTargets(files)).forEach((file, enhanced) {
    print (enhanced);
    new File(file.replaceFirst(new RegExp(r'.dart$'), '.e.dart')).writeAsStringSync(enhanced.join('\n\n'));
  });
}

Map<String, String> _findTargets (List<String> paths) {
  Map<String, String> targets = <String, String>{};
  paths.forEach((target) {
    switch (FileSystemEntity.typeSync(target, followLinks: false)) {
      case FileSystemEntityType.DIRECTORY:
        targets.addAll(_findTargets(new Directory(target).listSync(recursive: false,
            followLinks: false).map((entity) => entity.path)
            .toList(growable: false)));
        break;
      case FileSystemEntityType.FILE:
        if (!target.endsWith('.e.dart')) {
          File f = new File(target);
          targets[f.path] = f.readAsStringSync();
        }
        break;
    }
  });
  return targets;
}

Task enhanceTask () {
  return new Task ((TaskContext ctx) {
    _enhance(ctx.arguments.rest);
  }, description: 'Enhance list of target files');
}