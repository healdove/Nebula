import argparse
import datetime
import shutil
import sys
import os
import subprocess

def canonicalize(path):
    if os.path.islink(path):
        with open(path, 'rb') as f:
            contents = f.read()
        os.remove(path)
        with open(path, 'wb') as f:
            f.write(contents)

class Checker:
    def __init__(self, log_lines):
        self.log_lines = log_lines
        self.failed = False

    def log_check(self, desc, fragment):
        self._log_check(desc, lambda l: fragment in l, any)

    def log_check_fail(self, desc, fragment):
        self._log_check(desc, lambda l: fragment not in l, all)

    def _log_check(self, desc, eval_f, comb):
        verdict = comb(eval_f(l) for l in self.log_lines)
        if verdict:
            print(f'\033[32mPASS : "{desc}"\033[0m', file=sys.stderr)
        else:
            print(f'\033[31mFAIL : "{desc}"\033[0m', file=sys.stderr)
            self.failed = True

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--test_root', required=True)
    parser.add_argument('--dd_bin', required=True)
    parser.add_argument('--dmb_file', required=True)
    parser.add_argument('--rsc_file', required=True)
    args = parser.parse_args()

    os.chdir(args.test_root)
    os.chdir(os.path.dirname(args.dmb_file) or '.')

    canonicalize(args.dmb_file)
    canonicalize(args.rsc_file)

    proc = subprocess.Popen([args.dd_bin, os.path.basename(args.dmb_file), '-trusted'], text=True, stdout=sys.stdout, stderr=subprocess.PIPE)

    runtimes = 0
    sched_fails = 0
    warns = 0
    errors = 0

    pass_tests = False
    pass_runtimes = False

    log_lines = []

    for line in proc.stderr:
        sys.stderr.write(f'{datetime.datetime.now()} {line}')
        log_lines.append(line)
        if 'All Unit Tests Passed' in line:
            pass_tests = True
        if 'Caught 0 Runtimes' in line:
            pass_runtimes = True
        if 'runtime_error:' in line:
            runtimes += 1
        if 'Process scheduler caught exception processing' in line:
            sched_fails += 1
        if 'WARNING:' in line:
            warns += 1
        if 'ERROR:' in line:
            errors += 1

    proc.communicate()
    resp = proc.returncode

    if resp != 0:
        exit(1)

    check = Checker(log_lines)
    check.log_check('check tests passed', 'All Unit Tests Passed')
    check.log_check('check no runtimes', 'Caught 0 Runtimes')
    check.log_check_fail('check no runtimes 2', 'runtime error:')
    check.log_check_fail('check no scheduler failures', 'Process scheduler caught exception processing')
    check.log_check_fail('check no warnings', 'WARNING:')
    check.log_check_fail('check no errors', 'ERROR:')

    if check.failed:
        exit(1)