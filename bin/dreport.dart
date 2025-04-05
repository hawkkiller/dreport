import 'package:dreport/src/cli/runner.dart';

void main(List<String> args) {
  final commandRunner = DReportCommandRunner();
  commandRunner.run(args);
}
