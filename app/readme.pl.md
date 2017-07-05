*__Lasers flying in the sky__. Polish readme.*

# Założenia projektu

* Poznanie frameworka do tworzenia gier `love2d`.
* Napisanie grywalnego kawałka kodu.

# Opis działania

Po uruchomieniu, wciskamy jakikolwiek guzik na padzie, aby podłączyć się do gry. Aby wygrać, staramy się zniszczyć **kryształy** (czerwone obracające się prostokąty) przeciwnika, bądź samego **robota** przeciwnika (kolorowe kółko, które reaguje kiedy ruszysz lewym drążkiem pada kolegi). 

## Architektura kodu

Program napisany jest jako *Entity Component System* wsparty dziedziczeniem prototypowym przez bibliotekę `middleclass`.

# Wymagania sprzętowe

Dwa gamepady.

Gra powinna działać na jakimkolwiek komputerze osobistym wyprodukowanym po 2007 roku.

# Sposób uruchomienia

Folder `app` przeciągamy na plik wykonywalny `love2d`.

Możemy też spakować grę wraz silnikiem poprzez:

```ruby 
   Unix:
     cat love.exe SuperGame.love > SuperGame.exe

   Windows:
     copy /b love.exe+SuperGame.love SuperGame.exe
```

