# xiaomi-watchface-maker

Some tools and scripts to make it easier to create watch faces for Xiaomi brand smart watches.

## Usage

Modify the `config.json` file to design your watchface, then call `make`. Once
that's done, all the assets are in the `out` folder. To package that into a
`.bin` file, see the next section

## Packaging into a .bin file

Get this repository:

`git clone https://llmanull@bitbucket.org/valeronm/amazfitbiptools.git`

Then we need Mono to compile it.

`sudo apt update && sudo apt install dirmngr gnupg apt-transport-https ca-certificates`

`sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF`

`sudo sh -c 'echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" > /etc/apt/sources.list.d/mono-official-stable.list'`

`sudo apt update && sudo apt install mono-complete monodevelop`

Open the project in `monodevelop`:

`monodevelop Amazfit.sln`

* Switch from Debug to Release
* Pick Build All

Then the executable can be run with `mono`:

`mono ./WatchFace/bin/Release/WatchFace.exe /the/path/to/your/watchface/out/layout.json`

That will produce a file 'layout_packed.bin' that you can then send to your
watch, for instance using the Android app "Notify & Fitness for Amazfit".
