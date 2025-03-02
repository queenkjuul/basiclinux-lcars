��    U      �  q   l      0  �   1  �    t  �	  *  j  �  �     �     �      �     �     �  ,         -  %   K  ,   q  -   �      �  &   �          4  "   T  3   w  /   �  +   �  N        V     n  ?   �  !   �  /   �  �        �  &   �       �  0  ,  �  �  �  �  �     W"     g"  8   �"  6   �"     �"  *   #  ;   ?#     {#     �#     �#     �#  $   �#  $   $     3$     L$     j$  *   �$  "   �$     �$  6   �$     "%     8%  3   U%  "   �%     �%  G   �%     &     "&     8&     Q&     c&     w&  F   �&     �&  7   �&     ''     6'  +   F'  1   r'  *   �'  '   �'     �'     
(  8   $(  !   ](     (     �(  .  �(  �   �)  y  �*  $  9,  �  ^.  �  2     �4     �4     5     .5     E5  +   ^5     �5  "   �5  +   �5  ,   �5      $6  &   E6     l6     �6  !   �6  5   �6  $   7  &   )7  d   P7     �7     �7  A   �7     &8  "   E8  �   h8     *9  +   :9     f9  �  }9  '  <  �  >>  �  �A     �D     �D  9   �D  7   E  !   KE  +   mE  N   �E     �E     �E     F     1F  $   KF  $   pF     �F     �F  #   �F  2   �F  #   'G     KG  *   ^G  !   �G     �G  .   �G     �G     H  >   'H     fH     }H     �H     �H     �H     �H  @   �H     >I  7   VI  	   �I  	   �I  8   �I  '   �I  1   J  -   5J     cJ     tJ  A   �J  #   �J     �J     K     ,   R      9   S          	   8   I   +      ?   *       %   >   G   D      T   $                                            !   H       3          ;   2   O   A                 4       
   K       @         1         )      C   Q   /          -      #       =   0   U   <   J   "   F                 &   7           (   B   N       .   :       P                                        '   M   L       5         6   E    
Convert binary .mo files to Uniforum style .po files.
Both little-endian and big-endian .mo files are handled.
If no input file is given or it is -, standard input is read.
By default the output is written to standard output.
 
If the TEXTDOMAIN parameter is not given, the domain is determined from the
environment variable TEXTDOMAIN.  If the message catalog is not found in the
regular directory, another location can be specified with the environment
variable TEXTDOMAINDIR.
When used with the -s option the program behaves like the `echo' command.
But it does not simply copy its arguments to stdout.  Instead those messages
found in the selected catalog are translated.
Standard search directory: %s
 
Merges two Uniforum style .po files together.  The def.po file is an
existing PO file with the old translations which will be taken over to
the newly created file as long as they still match; comments will be
preserved, but extract comments and file positions will be discarded.
The ref.po file is the last created PO file (generally by xgettext), any
translations or comments in the file will be discarded, however dot
comments and file positions will be preserved.  Where an exact match
cannot be found, fuzzy matching is used to produce better results.  The
results are written to stdout unless an output file is specified.
   -h, --help                     display this help and exit
  -i, --indent                   write the .po file using indented style
  -j, --join-existing            join messages with existing file
  -k, --keyword[=WORD]           additonal keyword to be looked for (without
                                 WORD means not to use default keywords)
  -l, --string-limit=NUMBER      set string length limit to NUMBER instead %u
  -L, --language=NAME            recognise the specified language (C, C++, PO),
                                 otherwise is guessed from file extension
  -m, --msgstr-prefix[=STRING]   use STRING or "" as prefix for msgstr entries
  -M, --msgstr-suffix[=STRING]   use STRING or "" as suffix for msgstr entries
      --no-location              do not write '#: filename:line' lines
   -n, --add-location             generate '#: filename:line' lines (default)
      --omit-header              don't write header with `msgid ""' entry
  -o, --output=FILE              write output to specified file
  -p, --output-dir=DIR           output files will be placed in directory DIR
  -s, --sort-output              generate sorted output and remove duplicates
      --strict                   write out strict Uniforum conforming .po file
  -T, --trigraphs                understand ANSI C trigraphs for input
  -V, --version                  output version information and exit
  -w, --width=NUMBER             set output page width
  -x, --exclude-file=FILE        entries from FILE are not extracted

If INPUTFILE is -, standard input is read.
  done.
 %d translated messages %s and %s are mutually exclusive %s: illegal option -- %c
 %s: invalid option -- %c
 %s: option `%c%s' doesn't allow an argument
 %s: option `%s' is ambiguous
 %s: option `%s' requires an argument
 %s: option `--%s' doesn't allow an argument
 %s: option `-W %s' doesn't allow an argument
 %s: option `-W %s' is ambiguous
 %s: option requires an argument -- %c
 %s: unrecognized option `%c%s'
 %s: unrecognized option `--%s'
 %s: warning: no header entry found %s: warning: source file contains fuzzy translation %s:%d: warning: unterminated character constant %s:%d: warning: unterminated string literal %sRead %d old + %d reference, merged %d, fuzzied %d, missing %d, obsolete %d.
 , %d fuzzy translations , %d untranslated messages --join-existing cannot be used when output is written to stdout ...but this definition is similar ...this is the location of the first definition Copyright (C) %s Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 Memory exhausted Try `%s --help' for more information.
 Unknown system error Usage: %s [OPTION] [FILE]...
Mandatory arguments to long options are mandatory for short options too.
  -e, --no-escape          do not use C escapes in output (default)
  -E, --escape             use C escapes in output, no extended chars
      --force-po           write PO file even if empty
  -h, --help               display this help and exit
  -i, --indent             write indented output style
  -o, --output-file=FILE   write output into FILE instead of standard output
      --strict             write strict uniforum style
  -V, --version            output version information and exit
  -w, --width=NUMBER       set output page width
 Usage: %s [OPTION] [[[TEXTDOMAIN] MSGID] | [-s [MSGID]...]]
  -d, --domain=TEXTDOMAIN   retrieve translated messages from TEXTDOMAIN
  -e                        enable expansion of some escape sequences
  -E                        (ignored for compatibility)
  -h, --help                display this help and exit
  -n                        suppress trailing newline
  -V, --version             display version information and exit
  [TEXTDOMAIN] MSGID        retrieve translated message corresponding
                            to MSGID from TEXTDOMAIN
 Usage: %s [OPTION] def.po ref.po
Mandatory arguments to long options are mandatory for short options too.
  -D, --directory=DIRECTORY   add DIRECTORY to list for input files search
  -e, --no-escape             do not use C escapes in output (default)
  -E, --escape                use C escapes in output, no extended chars
      --force-po              write PO file even if empty
  -h, --help                  display this help and exit
  -i, --indent                indented output style
  -o, --output-file=FILE      result will be written to FILE
      --no-location           suppress '#: filename:line' lines
      --add-location          preserve '#: filename:line' lines (default)
      --strict                strict Uniforum output style
  -v, --verbose               increase verbosity level
  -V, --version               output version information and exit
  -w, --width=NUMBER          set output page width
 Usage: %s [OPTION] def.po ref.po
Mandatory arguments to long options are mandatory for short options too.
  -D, --directory=DIRECTORY   add DIRECTORY to list for input files search
  -h, --help                  display this help and exit
  -V, --version               output version information and exit

Compare two Uniforum style .po files to check that both contain the same
set of msgid strings.  The def.po file is an existing PO file with the
old translations.  The ref.po file is the last created PO file
(generally by xgettext).  This is useful for checking that you have
translated each and every message in your program.  Where an exact match
cannot be found, fuzzy matching is used to produce better diagnostics.
 Written by %s.
 `domain %s' directive ignored `msgid' and `msgstr' entries do not both begin with '\n' `msgid' and `msgstr' entries do not both end with '\n' cannot create output file "%s" domain name "%s" not suitable as file name domain name "%s" not suitable as file name: will use prefix duplicate message definition empty `msgstr' entry ignored end-of-file within string end-of-line within string error while opening "%s" for reading error while opening "%s" for writing error while reading "%s" error while writing "%s" file exactly 2 input files required field `%s' still has initial default value file "%s" is not in GNU .mo format file "%s" truncated format specifications for argument %u are not the same found %d fatal errors fuzzy `msgstr' entry ignored header field `%s' should start at beginning of line headerfield `%s' missing in header illegal control sequence internationalized messages should not contain the `\%c' escape sequence keyword "%s" unknown language `%s' unknown missing `msgstr' section missing arguments no input file given no input files given number of format specifications in `msgid' and `msgstr' does not match seek "%s" offset %ld failed some header fields still have the initial default value standard input standard output this file may not contain domain directives this message has no definition in the "%s" domain this message is used but not defined in %s this message is used but not defined... too many arguments too many errors, aborting warning: file `%s' extension `%s' is unknown; will try C warning: this message is not used while creating hash table while preparing output Project-Id-Version: GNU gettext 0.10.30
POT-Creation-Date: 1998-04-30 22:50-0700
PO-Revision-Date: 1997-09-03 12:52+0900
Last-Translator: Bang Jun-Young <bangjy@geocities.com>
Language-Team: Korean <ko@li.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 8-bit
 
���� .mo ������ Uniforum ������ .po ���Ϸ� ��ȯ�մϴ�.
��Ʋ-������ ��-��������� �� .mo ������ ��� �ٷ� �� �ֽ��ϴ�.
�Է� ������ �־����� �ʰų� - �̸� ǥ�� �Է��� �а� �˴ϴ�.
���������� ����� ǥ�� ��¿� ��ϵ˴ϴ�.
 
TEXTDOMAIN �Ű������� �־����� ������ ������ ȯ�� ���� TEXTDOMAIN���κ���
�����˴ϴ�.  �޽��� ����� �Ϲ����� ���丮�� ���� ������ ȯ�� ����
TEXTDOMAINDIR�� �ٸ� ��ġ�� ������ �� �ֽ��ϴ�.
-s �ɼ��� ���̸� ���α׷��� `echo' ����ó�� �����մϴ�. �׷��� �ܼ��� �μ���
ǥ����¿� ���������� �ʽ��ϴ�.  ��� ���õ� ��Ͽ� �ִ� ������ �޽�����
��µ˴ϴ�.
�⺻ Ž�� ���丮: %s
 
Uniforum ������ �� ������ �ϳ��� �����մϴ�.  def.po ������ �̹� �����ϴ�
�����̸� ������ ������ �޽����� ��� �ֽ��ϴ�.  �� ���������� ¦�� �ִ� �Ϳ�
���� ���Ӱ� ������� ������ ������ ��ü�˴ϴ�; �ּ��� ���������� ���� �ּ���
���� ��ġ�� ���ŵ˴ϴ�.  ref.po ������ �ֱٿ� ������� PO �����̸�
(�Ϲ������� xgettext�� ����), ���� ���� ��� �������̳� �ּ��� ���ŵ�����
�� �ּ��� ���� ��ġ�� �����˴ϴ�.  ��Ȯ�� ¦�� ã�� ���� ���, ���� ����
����� ��� ���� ���� ��Ī�� ���˴ϴ�.  ���� ��� ������ �������� ������
����� ǥ����¿� �������ϴ�.
   -h, --help                     �� ������ �����ְ� �����մϴ�
  -i, --indent                   �鿩����� ���·� .po ���Ͽ� ����մϴ�
  -j, --join-existing            �����ϴ� ���Ͽ� �޽����� �����մϴ�
  -k, --keyword[=WORD]           �ΰ������� Ž���� Ű���� (WORD�� ��������
                                 �ʴ� ���� ������ Ű���带 ���� ���� ������
                                 �ʽ��ϴ�)
  -l, --string-limit=NUMBER      ���ڿ��� ���̸� %u ��� NUMBER�� �����մϴ�
  -L, --language=NAME            ������ ���(C, C++, PO)�� �ν��ϸ�, �׷��� ����
                                 ������ ���� Ȯ���ڸ� ���� �����մϴ�.
  -m, --msgstr-prefix[=STRING]   msgstr �׸��� ���λ�� STRING�̳� ""��
                                 ����մϴ�
  -M, --msgstr-suffix[=STRING]   msgstr �׸��� ���̻�� STRING�̳� ""��
                                 ����մϴ�
      --no-location              '#: filename:line' ���� ���� �ʽ��ϴ�
   -n, --add-location             '#: filename:line' ���� �����մϴ� (������)
      --omit-header              ǥ���� `msgid ""' �׸��� ���� �ʽ��ϴ�
  -o, --output=FILE              ������ ���Ͽ� ����� ����մϴ�
  -p, --output-dir=DIR           ��� ������ DIR ���丮�� ������ �����ϴ�
  -s, --sort-output              ���ĵ� ����� �����ϰ� �纻�� ����ϴ�
      --strict                   Uniforum�� ������ ������ .po ������ ����ϴ�
  -T, --trigraphs                �Է¿� ���� ANSI C Ʈ���׶����� �ν��մϴ�
  -V, --version                  ���� ������ ����ϰ� �����մϴ�
  -w, --width=NUMBER             ��� ������ ���� �����մϴ�
  -x, --exclude-file=FILE        FILE ���� �׸��� �������� �ʽ��ϴ�

�Է������� - �̸� ǥ�� �Է��� �а� �˴ϴ�.
  �Ϸ�.
 ������ �޽��� %d�� %s�� %s�� ���� ��Ÿ���Դϴ� %s: �߸��� �ɼ� -- %c
 %s: �������� �ɼ� -- %c
 %s: `%c%s' �ɼ��� �μ��� ������� �ʽ��ϴ�
 %s: `%s'�� ��ȣ�� �ɼ��Դϴ�
 %s: `%s' �ɼ��� �μ��� �ʿ��մϴ�
 %s: `--%s' �ɼ��� �μ��� ������� �ʽ��ϴ�
 %s: `-W %s' �ɼ��� �μ��� ������� �ʽ��ϴ�
 %s: `-W %s'�� ��ȣ�� �ɼ��Դϴ�
 %s: �� �ɼ��� �μ��� �ʿ��մϴ� -- %c
 %s: �ν��� �� ���� �ɼ� `%c%s'
 %s: �ν��� �� ���� �ɼ� `--%s'
 %s: ���: ��� �׸��� ã�� ������ %s: ���: �ҽ� ������ ���� �������� �����ϰ� �ֽ��ϴ� %s:%d: ���: �ϰ���� ���� ���� ��� %s:%d: ���: �ϰ���� ���� ���ڿ� ��� %s%d���� ���� �� + %d���� ������, ���յ� �� %d, ���� %d, ���� �� %d, ������� �� %d���� �о����ϴ�.
 , ���� ������ %d�� , �������� ���� �޽��� %d�� --join-exeisting�� ����� ǥ����¿� ������ �� ���� �� �����ϴ� ...������ �� ���Ǵ� �����մϴ� ...����� ù��° ������ ��ġ�Դϴ� ���۱� (C) %s Free Software Foundation, Inc.
�� ���α׷��� ���� ����Ʈ�����Դϴ�.  ���� ������ �ҽ��� �����Ͻʽÿ�. ��ǰ��
�̳� Ư�� ������ ���� ���ռ��� ����Ͽ�, ��� ������ ���� �ʽ��ϴ�.
 �޸𸮰� �ٴڳ� �� ���� ������ ������ `%s --help' �Ͻʽÿ�
 �� �� ���� �ý��� ���� ����: %s [�ɼ�] [����]...
�� �ɼǿ� �ΰ��Ǵ� �μ��� ª�� �ɼǿ��� ����˴ϴ�.
  -e, --no-escape          ��¿� C �̽������� ���ڸ� ���� �ʽ��ϴ� (������)
  -E, --escape             ��¿� C �̽������� ���ڸ� ����, Ȯ�� ���ڴ� ����
                           �ʽ��ϴ�
      --force-po           ��������� PO ���Ͽ� ����մϴ�
  -h, --help               �� ������ �����ְ� �����մϴ�
  -i, --indent             �鿩����� ��� ����
  -o, --output-file=FILE   ����� FILE�� ���������� �մϴ�
      --strict             ������ Uniforum ��� ����
  -V, --version            ���� ������ ����ϰ� �����մϴ�
  -w, --width=NUMBER       ��� ������ ���� �����մϴ�
 ����: %s [�ɼ�] [[[TEXTDOMAIN] MSGID] | [-s [MSGID]...]]
  -d, --domain=TEXTDOMAIN   ������ �޽����� TEXTDOMAIN���� �ҷ��ɴϴ�
  -e                        ��� �̽������� ���ڿ��� Ȯ���� ������ �մϴ�
  -E                        (ȣȯ���� ���� ���õ�)
  -h, --help                �� ������ �����ְ� �����մϴ�
  -n                        ����ٴ� �ٹٲ� ���ڸ� �����մϴ�
  -V, --version             ���� ������ ǥ���ϰ� �����մϴ�
  [TEXTDOMAIN] MSGID        MSGID�� �����ϴ� ������ �޽����� TEXTDOMAIN����
                            �ҷ��ɴϴ�
 ����: %s [�ɼ�] def.po ref.po
�� �ɼǿ� �ΰ��Ǵ� �μ��� ª�� �ɼǿ��� ����˴ϴ�.
  -D, --directory=DIRECTORY  �Է� ���� Ž�� ���ܿ� DIRECTORY�� �߰��մϴ�
  -e, --no-escape            ��¿� C �̽������� ���ڸ� ���� �ʽ��ϴ� (������)
  -E, --escape               ��¿� C �̽������� ���ڸ� ����, Ȯ�� ���ڴ� ����
                             �ʽ��ϴ�
      --force-po             ��������� PO ���Ͽ� ����մϴ�
  -h, --help                 �� ������ �����ְ� �����մϴ�
  -i, --indent               �鿩����� ��� ����
  -o, --output-file=FILE     ����� FILE�� ���������� �մϴ�
      --no-location          `#: filename:line' ���� ���� �ʽ��ϴ�
      --add-location         `#: filename:line' ���� �����մϴ� (������)
      --strict               ������ Uniforum ��� ����
  -v, --verbose              ǥ�� ����� ���Դϴ�
  -V, --version              ���� ������ ����ϰ� �����մϴ�
  -w, --width=NUMBER         ��� ������ ���� �����մϴ�
 ����: %s [�ɼ�] def.po ref.po
�� �ɼǿ� �ΰ��Ǵ� �μ��� ª�� �ɼǿ��� ����˴ϴ�.
  -D, --directory=DIRECTORY   �Է� ���� Ž�� ���ܿ� DIRECTORY�� �߰��մϴ�
  -h, --help                  �� ������ �����ְ� �����մϴ�
  -V, --version               ���� ������ ����ϰ� �����մϴ�

���� ������ msgid ���ڿ��� �����ϰ� �ִ��� Ȯ���ϱ� ���� Uniforum
������ �� .po ������ ���մϴ�.  def.po ������ �̹� �����ϴ� �����̸�
������ ������ �޽����� ��� �ֽ��ϴ�.  ref.po ������ �ֱٿ� �������
PO �����Դϴ�(�Ϲ������� xgettext�� ����).  �̰��� ���α׷� ���� �ִ�
������ �޽����� �����ߴ��� Ȯ���� �� �����մϴ�.  ��Ȯ�� ¦�� ã�� ����
���, ���� ���� ����� ��� ���� ���� ��Ī�� ���˴ϴ�.
 %s�� ��������ϴ�.
 `domain %s' �����ڴ� ���õ� `msgid'�� `msgstr' �׸��� ��� '\n'���� �������� �ʽ��ϴ� `msgid'�� `msgstr' �׸��� ��� '\n'���� ������ �ʽ��ϴ� ��� ���� "%s"�� ���� �� �����ϴ� ������ "%s"�� ���� �̸����� �˸��� �ʽ��ϴ� ������ "%s"�� ���� �̸����� �˸��� �ʽ��ϴ�. �׷��Ƿ� ���λ縦
����� ���Դϴ� �ߺ��� �޽��� ���� �� `msgstr' �׸��� ���õ� ���ڿ� ���ο��� ������ ���� ���ڿ� ���ο��� ���� ���� �б� ���� "%s"�� ���� ���� ���� �߻� ���� ���� "%s"�� ���� ���� ���� �߻� "%s"�� �д� ���� ���� �߻� "%s" ������ ���� ���� ���� �߻� ��Ȯ�� 2���� �Է� ������ �ʿ��մϴ� `%s' �ʵ尡 ������ �ʱ��� �������� ������ �ֽ��ϴ� "%s" ������ GNU .mo ������ �ƴմϴ� "%s" ������ �߷��� �μ� %u�� ���� ���� �����ڰ� ���� �ʽ��ϴ� %d���� ġ������ ������ ã�ҽ��ϴ� ���� `msgstr' �׸��� ���õ� ��� �ʵ� `%s'�� ���� ó������ �����ؾ� �մϴ� ����� ����ʵ� `%s'�� ������ �߸��� ���� ������ ����ȭ�� �޽����� `\%c' �̽������� �������� ������ �� �����ϴ� �� �� ���� Ű���� "%s" `%s' �� �� �� ���� `msgstr' �κ��� �������ϴ� �μ��� ������ �Է� ������ �־����� �ʾҽ��ϴ� �Է� ������ �־����� �ʾҽ��ϴ� `msgid'�� `msgstr'�� ���� ���� �������� ������ ��ġ���� �ʽ��ϴ� "%s" �ɼ� %ld Ž�� ���� ��� ��� �ʵ尡 ������ �ʱ��� �������� ������ �ֽ��ϴ� ǥ�� �Է� ǥ�� ��� �� ������ ���� �����ڸ� �����ϰ� ���� ���� ���� �ֽ��ϴ� �� �޽����� "%s" ������ ���ǰ� �����ϴ� �� �޽����� �������� %s���� ���ǵ��� �ʾҽ��ϴ� �� �޽����� �������� ���ǵ��� �ʾҽ��ϴ�... �μ��� �ʹ� ���� ������ �ʹ� ���Ƽ� �ߴ��մϴ� ���: `%s' ������ Ȯ���� `%s'�� �� �� �����ϴ�; C �������� ������ ���: �� �޽����� ������ �ʽ��ϴ� �ؽ� ���̺��� ����� ���� ����� �غ��ϴ� ���� 