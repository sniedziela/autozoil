autozoil
========

Autozoil is a comprehensive checker for texts written in (La)Tex,
mainly MSc theses and scientific papers. Autozoil has been used for
Polish and English texts so far. The program was created for checking
MSc theses supervised by Filip Graliński at the Faculty of Mathematics
and Computer Science of Adam Mickiewicz University in 2010/2011.

Autozoil to program do kompleksowego sprawdzania tekstów pisanych w
(La)TeX-u, głównie prac magisterskich i prac naukowych. Do tej pory
autozoil był używany do tekstów polskich i angielskich. Program
powstał przy okazji pisania prac magisterskich pod kierunkiem Filipa
Gralińskiego na Wydziale Matematyki i Informatyki Uniwersytetu im.
Adama Mickiewicza w roku akademickim 2010/2011.

Running / wywołanie
-------------------

    perl autozoil.pl --locale pl_PL tekst_po_polsku.tex

    perl autozoil.pl --locale en_GB text_in_english.tex

Modules / Moduły
----------------

The following modules are available in autozoil:

* `Chktex` - checking LaTeX stuff (ChkTeX is required, see
  http://baruch.ev-en.org/proj/chktex/),
* `Languagetool` - grammar checker (languagetool is required, see
  http://www.languagetool.org/),
* `LogAnalyser` - looks for warnings in TeX log files,
* `Spell` - spell checker (hunspell and its dictionaries are required,
   see http://hunspell.sourceforge.net/)
* `Typo` - various simple mistakes, like missing hard spaces.

Następujące moduły są dostępne w autozoilu:

* `Chktex` - wyszukiwanie technicznych błędów związanych LaTeX-em
  (wymagany ChkTeX, zob. http://baruch.ev-en.org/proj/chktex/),
* `Languagetool` - korektor gramatyczny (wymagany languagetool, zob.
  http://www.languagetool.org/),
* `LogAnalyser` - wyszukuje ostrzeżenia w logach TeX-a,
* `Spell` - korektor ortograficzny (wymagany hunspell i odpowiednie słowniki,
   zob. http://hunspell.sourceforge.net/)
* `Typo` - różne proste błędy, np. brakujące twarde spacje.

Authors / Autorzy
-----------------

* Filip Graliński
* Mirosław Zemski
* Roman Grundkiewicz
* Jakub Gruszecki
* Jan Legutko
* Kajetan Wilczek

Suppressing warnings
--------------------

[Only in Polish for the time being.]

Czasami istnieje potrzeba "uciszania" błędów zgłaszanych autozoila. W
związku z tym została wprowadzona możliwość "uciszania" błędów za
pomocą dwóch konstrukcji:

1) % --|SPECS

Ucisza wskazane w SPECS błędy w danym, pojedynczym wierszu.

2)

% --<SPECS
.....
.....
.....
% -->

Ucisza wskazane w SPECS błędy w całym obszarze. (% --> zamyka "uciszany" obszar).

(W obu przypadkach między znakiem '%' a '--' może wystąpić dowolna
liczba spacji - w szczególności zero).

SPECS to lista specyfikacji oddzielonych przecinkami. Każda
specyfikacja to:
- etykieta błędu (tj. pierwsze pole w wyjściu autozoila), np. grammar-BRAK_SPACJI,
  spell-search czy latex-36
- zamiast właściwej etykiety po '-' można dać '*', co oznacza
  wyciszenie wszystkich błędów danego typu (np. spell-*).

Uwaga: jeśli zostanie napotkane uciszenie, dla którego błąd wcale nie
wystąpił (zbędne uciszenie), jest to zgłaszane jako błąd! W przypadku
specyfikacji z '*' muszą wystąpić przynajmniej 3 błędy.
