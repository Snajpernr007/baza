-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 16, 2025 at 01:06 PM
-- Wersja serwera: 10.4.32-MariaDB
-- Wersja PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `baza_max`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `dostawcy`
--

CREATE TABLE `dostawcy` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dostawcy`
--

INSERT INTO `dostawcy` (`id`, `nazwa`) VALUES
(1, 'dostawca1'),
(2, 'dostawca2'),
(5, 'nic'),
(3, 'test1'),
(4, 'ttttttr');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `lokalizacja`
--

CREATE TABLE `lokalizacja` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `lokalizacja`
--

INSERT INTO `lokalizacja` (`id`, `nazwa`) VALUES
(1, 'Magazyn1');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `profil`
--

CREATE TABLE `profil` (
  `id` int(11) NOT NULL,
  `id_tasmy` int(11) NOT NULL,
  `data_produkcji` date NOT NULL,
  `godz_min_rozpoczecia` time NOT NULL,
  `godz_min_zakonczenia` time NOT NULL,
  `zwrot_na_magazyn_kg` decimal(10,2) DEFAULT NULL,
  `nr_czesci_klienta` varchar(50) NOT NULL,
  `nazwa_klienta_nr_zlecenia_PRODIO` varchar(100) DEFAULT NULL,
  `id_pracownika` int(11) NOT NULL,
  `Data_do_usuwania` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `szablon`
--

CREATE TABLE `szablon` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL,
  `rodzaj` varchar(255) NOT NULL,
  `grubosc_i_oznaczenie_ocynku` varchar(255) NOT NULL,
  `grubosc` decimal(10,2) NOT NULL,
  `szerokosc` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `szablon`
--

INSERT INTO `szablon` (`id`, `nazwa`, `rodzaj`, `grubosc_i_oznaczenie_ocynku`, `grubosc`, `szerokosc`) VALUES
(1, 'Dx2', 'D', 'x', 77.00, 3.00),
(2, 'TT', 't', 'r', 1.00, 1.00),
(3, 'DX510 2275 1,2x66', 'DX510', '2275', 1.00, 66.00),
(4, 'ww ww wwxww', 'ww', 'ww', 0.00, 0.00),
(5, '22 22 TruexTrue', '22', '22', 1.00, 1.00),
(6, 't t TruexTrue', 't', 't', 1.00, 1.00),
(7, '11 11 11x11', '11', '11', 11.00, 11.00),
(8, '121 122 8.1x8.2', '121', '122', 8.20, 8.10),
(9, 'ttr 4ewr 4,2x4', 'ttr', '4ewr', 4.20, 4.00),
(10, 'ttr20 mc4 4x5', 'ttr20', 'mc4', 5.00, 4.00);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `tasma`
--

CREATE TABLE `tasma` (
  `id` int(11) NOT NULL,
  `data_z_etykiety_na_kregu` date NOT NULL,
  `grubosc` decimal(10,2) NOT NULL,
  `szerokosc` decimal(10,2) NOT NULL,
  `waga_kregu` decimal(10,2) NOT NULL,
  `waga_kregu_na_stanie` decimal(10,2) NOT NULL,
  `nr_etykieta_paletowa` varchar(255) NOT NULL,
  `nr_z_etykiety_na_kregu` varchar(255) NOT NULL,
  `lokalizacja_id` int(11) DEFAULT NULL,
  `nr_faktury_dostawcy` varchar(255) NOT NULL,
  `data_dostawy` date NOT NULL,
  `pracownik_id` int(11) DEFAULT NULL,
  `dostawca_id` int(11) NOT NULL,
  `szablon_id` int(11) NOT NULL,
  `Data_do_usuwania` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `uprawnienia`
--

CREATE TABLE `uprawnienia` (
  `id_uprawnienia` int(11) NOT NULL,
  `nazwa` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `uprawnienia`
--

INSERT INTO `uprawnienia` (`id_uprawnienia`, `nazwa`) VALUES
(1, 'Administrator'),
(2, 'Zaopatrzeniowiec '),
(3, 'Pracownik');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `uzytkownicy`
--

CREATE TABLE `uzytkownicy` (
  `id` int(11) NOT NULL,
  `login` text DEFAULT NULL,
  `haslo` text NOT NULL,
  `id_uprawnienia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `uzytkownicy`
--

INSERT INTO `uzytkownicy` (`id`, `login`, `haslo`, `id_uprawnienia`) VALUES
(1, 'Administrator', 'scrypt:32768:8:1$hFji6Y2E4ieYI6Bp$d019011fb8ea6f21b31c18f54dbbf95f664ed512a7ffc0bb4a2a9b28b709e5fd7b5766675d7a7223aacc24bfdae9b038c22d61f6a1d00a212611c80e068ec153', 1),
(14, 'test1', 'scrypt:32768:8:1$g85jfiQGw8D1zVS1$61a4ed4d2ef9a2530b54939d1d472b43b61348c7c11ce5861e434799ec28999ac8e0373060f41d3b0e32e867794e839fa270277770a5f81e451aaf500c15109b', 1),
(16, 'test3', 'scrypt:32768:8:1$3zFtfjuCE2ekzMrt$9b1fa256e8c9b2e762949d17a45b6cfe2d544ea726da11fc7688676321ca63c029939ff18cba7b299e6d49f7029875c427282243b6078fbdb29e3de9dfe535d6', 3),
(17, 'test4', 'scrypt:32768:8:1$t3iQxJMK4QQE0eJg$d901c7265ccbf9c12a42dc7dab5974da829e86641ccafc6629e51588cd82db1235c61b3c6ab2ed648fc16c1ad0d1c300f1925f283b9124c78bd1c1eee33f5ed2', 1);

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `dostawcy`
--
ALTER TABLE `dostawcy`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nazwa` (`nazwa`);

--
-- Indeksy dla tabeli `lokalizacja`
--
ALTER TABLE `lokalizacja`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `profil`
--
ALTER TABLE `profil`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_tasmy` (`id_tasmy`),
  ADD KEY `id_pracownika` (`id_pracownika`);

--
-- Indeksy dla tabeli `szablon`
--
ALTER TABLE `szablon`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nazwa` (`nazwa`);

--
-- Indeksy dla tabeli `tasma`
--
ALTER TABLE `tasma`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tasma_pracownik` (`pracownik_id`),
  ADD KEY `fk_tasma_dostawca` (`dostawca_id`),
  ADD KEY `fk_tasma_szablon` (`szablon_id`),
  ADD KEY `fk_tasma_lokalizacja` (`lokalizacja_id`);

--
-- Indeksy dla tabeli `uprawnienia`
--
ALTER TABLE `uprawnienia`
  ADD PRIMARY KEY (`id_uprawnienia`);

--
-- Indeksy dla tabeli `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_uzytkownicy_uprawnienia` (`id_uprawnienia`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `dostawcy`
--
ALTER TABLE `dostawcy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `lokalizacja`
--
ALTER TABLE `lokalizacja`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `profil`
--
ALTER TABLE `profil`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `szablon`
--
ALTER TABLE `szablon`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `tasma`
--
ALTER TABLE `tasma`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `uprawnienia`
--
ALTER TABLE `uprawnienia`
  MODIFY `id_uprawnienia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `profil`
--
ALTER TABLE `profil`
  ADD CONSTRAINT `profil_ibfk_1` FOREIGN KEY (`id_tasmy`) REFERENCES `tasma` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `profil_ibfk_2` FOREIGN KEY (`id_pracownika`) REFERENCES `uzytkownicy` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tasma`
--
ALTER TABLE `tasma`
  ADD CONSTRAINT `fk_tasma_dostawca` FOREIGN KEY (`dostawca_id`) REFERENCES `dostawcy` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tasma_lokalizacja` FOREIGN KEY (`lokalizacja_id`) REFERENCES `lokalizacja` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_tasma_pracownik` FOREIGN KEY (`pracownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tasma_szablon` FOREIGN KEY (`szablon_id`) REFERENCES `szablon` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  ADD CONSTRAINT `fk_uzytkownicy_uprawnienia` FOREIGN KEY (`id_uprawnienia`) REFERENCES `uprawnienia` (`id_uprawnienia`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
