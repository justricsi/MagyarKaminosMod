-- phpMyAdmin SQL Dump
-- version 4.2.11
-- http://www.phpmyadmin.net
--
-- Hoszt: 127.0.0.1
-- Létrehozás ideje: 2016. Jan 17. 10:57
-- Szerver verzió: 5.6.21
-- PHP verzió: 5.5.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Adatbázis: `farmerrp`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `foldek`
--

CREATE TABLE IF NOT EXISTS `foldek` (
`id` int(11) NOT NULL,
  `pickupX` float NOT NULL,
  `pickupY` float NOT NULL,
  `pickupZ` float NOT NULL,
  `ar` int(11) NOT NULL,
  `tulaj` int(11) NOT NULL,
  `pickup` int(11) NOT NULL DEFAULT '1239',
  `meret` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- A tábla adatainak kiíratása `foldek`
--

INSERT INTO `foldek` (`id`, `pickupX`, `pickupY`, `pickupZ`, `ar`, `tulaj`, `pickup`, `meret`) VALUES
(1, 1078.77, 231.434, 30.8982, 12000000, 0, 1239, 12),
(2, 1169.62, 518.342, 19.7345, 5000000, 0, 1239, 5);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `jatekosok`
--

CREATE TABLE IF NOT EXISTS `jatekosok` (
`id` int(11) NOT NULL,
  `nev` varchar(25) NOT NULL,
  `jelszo` varchar(40) NOT NULL,
  `penz` int(11) NOT NULL,
  `pont` int(10) NOT NULL,
  `neme` int(10) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

--
-- A tábla adatainak kiíratása `jatekosok`
--

INSERT INTO `jatekosok` (`id`, `nev`, `jelszo`, `penz`, `pont`, `neme`) VALUES
(1, 'Auer_Richard', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 100000000, 0, 1),
(2, 'Justricsi', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 0, 0, 1),
(3, 'Justrics', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 0, 0, 1),
(4, 'Justricsii', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 0, 0, 1),
(5, 'Ricsike', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 0, 0, 1),
(6, 'Ricsusz', '20461e94da17c7d8e3b5244dcbe233f305c72c0d', 0, 0, 1),
(7, 'Klucsik_David', '783bafc3c6c8441d4950330a0842469efe14ac60', 0, 0, 2),
(8, 'Jani', '783bafc3c6c8441d4950330a0842469efe14ac60', 0, 0, 2),
(9, 'Pisti', '783bafc3c6c8441d4950330a0842469efe14ac60', 0, 0, 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `foldek`
--
ALTER TABLE `foldek`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jatekosok`
--
ALTER TABLE `jatekosok`
 ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `foldek`
--
ALTER TABLE `foldek`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `jatekosok`
--
ALTER TABLE `jatekosok`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=10;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
