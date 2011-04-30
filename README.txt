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
wystąpił (zbędne uciszenie), jest to zgłaszane jako błąd!





