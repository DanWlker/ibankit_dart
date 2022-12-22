import 'package:flutter_test/flutter_test.dart';
import 'package:ibankit_dart/iban.dart';

void main() {
  group("IBAN", () {
    group("test IBAN.isValid", () {
      test("valid iban", () {
        expect(IBAN.isValid("BA391990440001200279"), true);
      });
      test("valid with spaces", () {
        expect(IBAN.isValid("DE89 3704 0044 0532 0130 00"), true);
      });
      test("bad iban", () {
        expect(IBAN.isValid("BA391990440001200278"), false);
      });
    });

    group("Test check digit", () {
      test("valid iban", () {
        final iban = IBAN("BA391990440001200279");
        expect(iban.getCountry()?.countryCode, "BA");
      });

      test("bad iban", () {
        expect(() {
          IBAN("BA391990440001200278");
        }, throwsException);
      });
    });

    group("Test toFormat", () {
      test("AD - 24 characters", () {
        final iban = IBAN("AD12 0001 2030 200359100100");
        expect(iban.toFormattedString(), "AD12 0001 2030 2003 5910 0100");
      });

      test("AE - 23 characters", () {
        final iban = IBAN("AE07 0331 234567890123456");
        expect(iban.toFormattedString(), "AE07 0331 2345 6789 0123 456");
      });
    });

    group("Test IBAN Version 80", () {
      test("AD", () {
        final iban = IBAN("AD12 0001 2030 200359100100");
        expect(iban.getCountry()?.countryCode, "AD");
        expect(iban.getBankCode(), "0001");
        expect(iban.getBranchCode(), "2030");
        expect(iban.getAccountNumber(), "200359100100");
      });

      test("AE", () {
        final iban = IBAN("AE07 0331 234567890123456");
        expect(iban.getCountry()?.countryCode, "AE");
        expect(iban.getBankCode(), "033");
        expect(iban.getAccountNumber(), "1234567890123456");
      });

      test("AL", () {
        final iban = IBAN("AL47212110090000000235698741");
        expect(iban.getCountry()?.countryCode, "AL");
        expect(iban.getBankCode(), "212");
        expect(iban.getBranchCode(), "1100");
        expect(iban.getNationalCheckDigit(), "9");
        expect(iban.getAccountNumber(), "0000000235698741");
      });

      test("AT", () {
        final iban = IBAN("AT611904300234573201");
        expect(iban.getCountry()?.countryCode, "AT");
        expect(iban.getBankCode(), "19043");
        expect(iban.getAccountNumber(), "00234573201");
      });

      test("AZ", () {
        final iban = IBAN("AZ21NABZ00000000137010001944");
        expect(iban.getCountry()?.countryCode, "AZ");
        expect(iban.getBankCode(), "NABZ");
        expect(iban.getAccountNumber(), "00000000137010001944");
      });

      test("BA", () {
        final iban = IBAN("BA391990440001200279");
        expect(iban.getCountry()?.countryCode, "BA");
        expect(iban.getBankCode(), "199");
        expect(iban.getBranchCode(), "044");
        expect(iban.getAccountNumber(), "00012002");
        expect(iban.getNationalCheckDigit(), "79");
      });

      test("BE", () {
        final iban = IBAN("BE68539007547034");
        expect(iban.getCountry()?.countryCode, "BE");
        expect(iban.getBankCode(), "539");
        expect(iban.getAccountNumber(), "0075470");
        expect(iban.getNationalCheckDigit(), "34");
      });

      test("BG", () {
        final iban = IBAN("BG80BNBG96611020345678");
        expect(iban.getCountry()?.countryCode, "BG");
        expect(iban.getBankCode(), "BNBG");
        expect(iban.getBranchCode(), "9661");
        expect(iban.getAccountType(), "10");
        expect(iban.getAccountNumber(), "20345678");
        expect(iban.getNationalCheckDigit(), null);
      });

      test("BH", () {
        final iban = IBAN("BH67BMAG00001299123456");
        expect(iban.getCountry()?.countryCode, "BH");
        expect(iban.getBankCode(), "BMAG");
        expect(iban.getAccountNumber(), "00001299123456");
      });

      test("BR", () {
        final iban = IBAN("BR9700360305000010009795493P1");
        expect(iban.getCountry()?.countryCode, "BR");
        expect(iban.getBankCode(), "00360305");
        expect(iban.getBranchCode(), "00001");
        expect(iban.getAccountNumber(), "0009795493");
        expect(iban.getAccountType(), "P");
        expect(iban.getOwnerAccountType(), "1");
      });

      test("BY", () {
        final iban = IBAN("BY13NBRB3600900000002Z00AB00");
        expect(iban.getCountry()?.countryCode, "BY");
        expect(iban.getBankCode(), "NBRB");
        expect(iban.getAccountType(), "3600");
        expect(iban.getAccountNumber(), "900000002Z00AB00");
      });

      test("CH", () {
        final iban = IBAN("CH9300762011623852957");
        expect(iban.getCountry()?.countryCode, "CH");
        expect(iban.getBankCode(), "00762");
        expect(iban.getAccountNumber(), "011623852957");
      });

      test("CR", () {
        final iban = IBAN("CR05015202001026284066");
        expect(iban.getCountry()?.countryCode, "CR");
        expect(iban.getBankCode(), "0152");
        expect(iban.getAccountNumber(), "02001026284066");
      });

      test("CY", () {
        final iban = IBAN("CY17002001280000001200527600");
        expect(iban.getCountry()?.countryCode, "CY");
        expect(iban.getBankCode(), "002");
        expect(iban.getBranchCode(), "00128");
        expect(iban.getAccountNumber(), "0000001200527600");
      });

      test("CZ", () {
        final iban = IBAN("CZ6508000000192000145399");
        expect(iban.getCountry()?.countryCode, "CZ");
        expect(iban.getBankCode(), "0800");
        expect(iban.getBranchCode(), "000019");
        expect(iban.getAccountNumber(), "2000145399");
      });

      test("DE", () {
        final iban = IBAN("DE89370400440532013000");
        expect(iban.getCountry()?.countryCode, "DE");
        expect(iban.getBankCode(), "37040044");
        expect(iban.getAccountNumber(), "0532013000");
      });

      test("DK", () {
        final iban = IBAN("DK5000400440116243");
        expect(iban.getCountry()?.countryCode, "DK");
        expect(iban.getBankCode(), "0040");
        expect(iban.getAccountNumber(), "0440116243");
      });

      test("DO", () {
        final iban = IBAN("DO28BAGR00000001212453611324");
        expect(iban.getCountry()?.countryCode, "DO");
        expect(iban.getBankCode(), "BAGR");
        expect(iban.getAccountNumber(), "00000001212453611324");
      });

      test("EE", () {
        final iban = IBAN("EE382200221020145685");
        expect(iban.getCountry()?.countryCode, "EE");
        expect(iban.getBankCode(), "22");
        expect(iban.getBranchCode(), "00");
        expect(iban.getAccountNumber(), "22102014568");
        expect(iban.getNationalCheckDigit(), "5");
      });

      test("ES", () {
        final iban = IBAN("ES9121000418450200051332");
        expect(iban.getCountry()?.countryCode, "ES");
        expect(iban.getBankCode(), "2100");
        expect(iban.getBranchCode(), "0418");
        expect(iban.getAccountNumber(), "0200051332");
        expect(iban.getNationalCheckDigit(), "45");
      });

      test("FI", () {
        final iban = IBAN("FI2112345600000785");
        expect(iban.getCountry()?.countryCode, "FI");
        expect(iban.getBankCode(), "123");
        expect(iban.getAccountNumber(), "45600000785");
      });

      test("FO", () {
        final iban = IBAN("FO6264600001631634");
        expect(iban.getCountry()?.countryCode, "FO");
        expect(iban.getBankCode(), "6460");
        expect(iban.getAccountNumber(), "000163163");
        expect(iban.getNationalCheckDigit(), "4");
      });

      test("FR", () {
        final iban = IBAN("FR1420041010050500013M02606");
        expect(iban.getCountry()?.countryCode, "FR");
        expect(iban.getBankCode(), "20041");
        expect(iban.getBranchCode(), "01005");
        expect(iban.getAccountNumber(), "0500013M026");
        expect(iban.getNationalCheckDigit(), "06");
      });

      test("GB", () {
        final iban = IBAN("GB29NWBK60161331926819");
        expect(iban.getCountry()?.countryCode, "GB");
        expect(iban.getBankCode(), "NWBK");
        expect(iban.getBranchCode(), "601613");
        expect(iban.getAccountNumber(), "31926819");
      });

      test("GE", () {
        final iban = IBAN("GE29NB0000000101904917");
        expect(iban.getCountry()?.countryCode, "GE");
        expect(iban.getBankCode(), "NB");
        expect(iban.getAccountNumber(), "0000000101904917");
      });

      test("GI", () {
        final iban = IBAN("GI75NWBK000000007099453");
        expect(iban.getCountry()?.countryCode, "GI");
        expect(iban.getBankCode(), "NWBK");
        expect(iban.getAccountNumber(), "000000007099453");
      });

      test("GL", () {
        final iban = IBAN("GL8964710001000206");
        expect(iban.getCountry()?.countryCode, "GL");
        expect(iban.getBankCode(), "6471");
        expect(iban.getAccountNumber(), "0001000206");
      });

      test("GR", () {
        final iban = IBAN("GR1601101250000000012300695");
        expect(iban.getCountry()?.countryCode, "GR");
        expect(iban.getBankCode(), "011");
        expect(iban.getBranchCode(), "0125");
        expect(iban.getAccountNumber(), "0000000012300695");
      });

      test("GT", () {
        final iban = IBAN("GT82TRAJ01020000001210029690");
        expect(iban.getCountry()?.countryCode, "GT");
        expect(iban.getBankCode(), "TRAJ");
        expect(iban.getCurrencyType(), "01");
        expect(iban.getAccountType(), "02");
        expect(iban.getAccountNumber(), "0000001210029690");
      });

      test("HR", () {
        final iban = IBAN("HR1210010051863000160");
        expect(iban.getCountry()?.countryCode, "HR");
        expect(iban.getBankCode(), "1001005");
        expect(iban.getAccountNumber(), "1863000160");
      });

      test("HU", () {
        final iban = IBAN("HU42117730161111101800000000");
        expect(iban.getCountry()?.countryCode, "HU");
        expect(iban.getBankCode(), "117");
        expect(iban.getBranchCode(), "7301");
        expect(iban.getBranchCheckDigit(), "6");
        expect(iban.getAccountNumber(), "111110180000000");
        expect(iban.getNationalCheckDigit(), "0");
      });

      test("IE", () {
        final iban = IBAN("IE29AIBK93115212345678");
        expect(iban.getCountry()?.countryCode, "IE");
        expect(iban.getBankCode(), "AIBK");
        expect(iban.getBranchCode(), "931152");
        expect(iban.getAccountNumber(), "12345678");
      });

      test("IL", () {
        final iban = IBAN("IL620108000000099999999");
        expect(iban.getCountry()?.countryCode, "IL");
        expect(iban.getBankCode(), "010");
        expect(iban.getBranchCode(), "800");
        expect(iban.getAccountNumber(), "0000099999999");
      });

      test("IQ", () {
        final iban = IBAN("IQ98NBIQ850123456789012");
        expect(iban.getCountry()?.countryCode, "IQ");
        expect(iban.getBankCode(), "NBIQ");
        expect(iban.getBranchCode(), "850");
        expect(iban.getAccountNumber(), "123456789012");
      });

      test("IS", () {
        final iban = IBAN("IS140159260076545510730339");
        expect(iban.getCountry()?.countryCode, "IS");
        expect(iban.getBankCode(), "0159");
        expect(iban.getBranchCode(), "26");
        expect(iban.getAccountNumber(), "007654");
        expect(iban.getIdentificationNumber(), "5510730339");
      });

      test("IT", () {
        final iban = IBAN("IT60X0542811101000000123456");
        expect(iban.getCountry()?.countryCode, "IT");
        expect(iban.getBankCode(), "05428");
        expect(iban.getBranchCode(), "11101");
        expect(iban.getAccountNumber(), "000000123456");
      });

      test("JO", () {
        final iban = IBAN("JO94CBJO0010000000000131000302");
        expect(iban.getCountry()?.countryCode, "JO");
        expect(iban.getBankCode(), "CBJO");
        expect(iban.getBranchCode(), "0010");
        expect(iban.getAccountNumber(), "000000000131000302");
      });

      test("KW", () {
        final iban = IBAN("KW81CBKU0000000000001234560101");
        expect(iban.getCountry()?.countryCode, "KW");
        expect(iban.getBankCode(), "CBKU");
        expect(iban.getAccountNumber(), "0000000000001234560101");
      });

      test("KZ", () {
        final iban = IBAN("KZ86125KZT5004100100");
        expect(iban.getCountry()?.countryCode, "KZ");
        expect(iban.getBankCode(), "125");
        expect(iban.getAccountNumber(), "KZT5004100100");
      });

      test("LB", () {
        final iban = IBAN("LB62099900000001001901229114");
        expect(iban.getCountry()?.countryCode, "LB");
        expect(iban.getBankCode(), "0999");
        expect(iban.getAccountNumber(), "00000001001901229114");
      });

      test("LC", () {
        final iban = IBAN("LC07HEMM000100010012001200013015");
        expect(iban.getCountry()?.countryCode, "LC");
        expect(iban.getBankCode(), "HEMM");
        expect(iban.getAccountNumber(), "000100010012001200013015");
      });

      test("LI", () {
        final iban = IBAN("LI21088100002324013AA");
        expect(iban.getCountry()?.countryCode, "LI");
        expect(iban.getBankCode(), "08810");
        expect(iban.getAccountNumber(), "0002324013AA");
      });

      test("LT", () {
        final iban = IBAN("LT121000011101001000");
        expect(iban.getCountry()?.countryCode, "LT");
        expect(iban.getBankCode(), "10000");
        expect(iban.getAccountNumber(), "11101001000");
      });

      test("LU", () {
        final iban = IBAN("LU280019400644750000");
        expect(iban.getCountry()?.countryCode, "LU");
        expect(iban.getBankCode(), "001");
        expect(iban.getAccountNumber(), "9400644750000");
      });

      test("LV", () {
        final iban = IBAN("LV80BANK0000435195001");
        expect(iban.getCountry()?.countryCode, "LV");
        expect(iban.getBankCode(), "BANK");
        expect(iban.getAccountNumber(), "0000435195001");
      });

      test("MC", () {
        final iban = IBAN("MC5811222000010123456789030");
        expect(iban.getCountry()?.countryCode, "MC");
        expect(iban.getBankCode(), "11222");
        expect(iban.getBranchCode(), "00001");
        expect(iban.getAccountNumber(), "01234567890");
        expect(iban.getNationalCheckDigit(), "30");
      });

      test("MD", () {
        final iban = IBAN("MD24AG000225100013104168");
        expect(iban.getCountry()?.countryCode, "MD");
        expect(iban.getBankCode(), "AG");
        expect(iban.getAccountNumber(), "000225100013104168");
      });

      test("ME", () {
        final iban = IBAN("ME25505000012345678951");
        expect(iban.getCountry()?.countryCode, "ME");
        expect(iban.getBankCode(), "505");
        expect(iban.getAccountNumber(), "0000123456789");
        expect(iban.getNationalCheckDigit(), "51");
      });

      test("MK", () {
        final iban = IBAN("MK07250120000058984");
        expect(iban.getCountry()?.countryCode, "MK");
        expect(iban.getBankCode(), "250");
        expect(iban.getAccountNumber(), "1200000589");
        expect(iban.getNationalCheckDigit(), "84");
      });

      test("MR", () {
        final iban = IBAN("MR1300020001010000123456753");
        expect(iban.getCountry()?.countryCode, "MR");
        expect(iban.getBankCode(), "00020");
        expect(iban.getBranchCode(), "00101");
        expect(iban.getAccountNumber(), "00001234567");
        expect(iban.getNationalCheckDigit(), "53");
      });

      test("MT", () {
        final iban = IBAN("MT84MALT011000012345MTLCAST001S");
        expect(iban.getCountry()?.countryCode, "MT");
        expect(iban.getBankCode(), "MALT");
        expect(iban.getBranchCode(), "01100");
        expect(iban.getAccountNumber(), "0012345MTLCAST001S");
      });

      test("MU", () {
        final iban = IBAN("MU17BOMM0101101030300200000MUR");
        expect(iban.getCountry()?.countryCode, "MU");
        expect(iban.getBankCode(), "BOMM01");
        expect(iban.getBranchCode(), "01");
        expect(iban.getAccountNumber(), "101030300200");
        expect(iban.getAccountType(), "000");
        expect(iban.getCurrencyType(), "MUR");
      });

      test("NL", () {
        final iban = IBAN("NL91ABNA0417164300");
        expect(iban.getCountry()?.countryCode, "NL");
        expect(iban.getBankCode(), "ABNA");
        expect(iban.getAccountNumber(), "0417164300");
      });

      test("NO", () {
        final iban = IBAN("NO9386011117947");
        expect(iban.getCountry()?.countryCode, "NO");
        expect(iban.getBankCode(), "8601");
        expect(iban.getAccountNumber(), "111794");
        expect(iban.getNationalCheckDigit(), "7");
      });

      test("PK", () {
        final iban = IBAN("PK36SCBL0000001123456702");
        expect(iban.getCountry()?.countryCode, "PK");
        expect(iban.getBankCode(), "SCBL");
        expect(iban.getAccountNumber(), "0000001123456702");
      });

      test("PL", () {
        final iban = IBAN("PL61109010140000071219812874");
        expect(iban.getCountry()?.countryCode, "PL");
        expect(iban.getBankCode(), "109");
        expect(iban.getBranchCode(), "0101");
        expect(iban.getAccountNumber(), "0000071219812874");
        expect(iban.getNationalCheckDigit(), "4");
      });

      test("PS", () {
        final iban = IBAN("PS92PALS000000000400123456702");
        expect(iban.getCountry()?.countryCode, "PS");
        expect(iban.getBankCode(), "PALS");
        expect(iban.getAccountNumber(), "000000000400123456702");
      });

      test("PT", () {
        final iban = IBAN("PT50000201231234567890154");

        expect(iban.getCountry()?.countryCode, "PT");
        expect(iban.getBankCode(), "0002");
        expect(iban.getBranchCode(), "0123");
        expect(iban.getAccountNumber(), "12345678901");
        expect(iban.getNationalCheckDigit(), "54");
      });

      test("QA", () {
        final iban = IBAN("QA58DOHB00001234567890ABCDEFG");
        expect(iban.getCountry()?.countryCode, "QA");
        expect(iban.getBankCode(), "DOHB");
        expect(iban.getAccountNumber(), "00001234567890ABCDEFG");
      });

      test("RO", () {
        final iban = IBAN("RO49AAAA1B31007593840000");
        expect(iban.getCountry()?.countryCode, "RO");
        expect(iban.getBankCode(), "AAAA");
        expect(iban.getAccountNumber(), "1B31007593840000");
      });

      test("RS", () {
        final iban = IBAN("RS35260005601001611379");
        expect(iban.getCountry()?.countryCode, "RS");
        expect(iban.getBankCode(), "260");
        expect(iban.getAccountNumber(), "0056010016113");
        expect(iban.getNationalCheckDigit(), "79");
      });

      test("SA", () {
        final iban = IBAN("SA0380000000608010167519");
        expect(iban.getCountry()?.countryCode, "SA");
        expect(iban.getBankCode(), "80");
        expect(iban.getAccountNumber(), "000000608010167519");
      });

      test("SC", () {
        final iban = IBAN("SC18SSCB11010000000000001497USD");
        expect(iban.getCountry()?.countryCode, "SC");
        expect(iban.getBankCode(), "SSCB");
        expect(iban.getBranchCode(), "11");
        expect(iban.getBranchCheckDigit(), "01");
        expect(iban.getAccountNumber(), "0000000000001497");
      });

      test("SE", () {
        final iban = IBAN("SE4550000000058398257466");
        expect(iban.getCountry()?.countryCode, "SE");
        expect(iban.getBankCode(), "500");
        expect(iban.getAccountNumber(), "0000005839825746");
        expect(iban.getNationalCheckDigit(), "6");
      });

      test("SI", () {
        final iban = IBAN("SI56263300012039086");
        expect(iban.getCountry()?.countryCode, "SI");
        expect(iban.getBankCode(), "26");
        expect(iban.getBranchCode(), "330");
        expect(iban.getAccountNumber(), "00120390");
        expect(iban.getNationalCheckDigit(), "86");
      });

      test("SK", () {
        final iban = IBAN("SK3112000000198742637541");
        expect(iban.getCountry()?.countryCode, "SK");
        expect(iban.getBankCode(), "1200");
        expect(iban.getAccountNumber(), "0000198742637541");
      });

      test("SM", () {
        final iban = IBAN("SM86U0322509800000000270100");
        expect(iban.getCountry()?.countryCode, "SM");
        expect(iban.getBankCode(), "03225");
        expect(iban.getBranchCode(), "09800");
        expect(iban.getAccountNumber(), "000000270100");
      });

      test("ST", () {
        final iban = IBAN("ST68000100010051845310112");
        expect(iban.getCountry()?.countryCode, "ST");
        expect(iban.getBankCode(), "0001");
        expect(iban.getBranchCode(), "0001");
        expect(iban.getAccountNumber(), "0051845310112");
      });

      test("SV", () {
        final iban = IBAN("SV62CENR00000000000000700025");
        expect(iban.getCountry()?.countryCode, "SV");
        expect(iban.getBankCode(), "CENR");
        expect(iban.getBranchCode(), "0000");
        expect(iban.getAccountNumber(), "0000000000700025");
      });

      test("TL", () {
        final iban = IBAN("TL380080012345678910157");
        expect(iban.getCountry()?.countryCode, "TL");
        expect(iban.getBankCode(), "008");
        expect(iban.getAccountNumber(), "00123456789101");
        expect(iban.getNationalCheckDigit(), "57");
      });

      test("TN", () {
        final iban = IBAN("TN5910006035183598478831");
        expect(iban.getCountry()?.countryCode, "TN");
        expect(iban.getBankCode(), "10");
        expect(iban.getBranchCode(), "006");
        expect(iban.getAccountNumber(), "0351835984788");
        expect(iban.getNationalCheckDigit(), "31");
      });

      test("TR", () {
        final iban = IBAN("TR330006100519786457841326");
        expect(iban.getCountry()?.countryCode, "TR");
        expect(iban.getBankCode(), "00061");
        expect(iban.getAccountNumber(), "0519786457841326");
        expect(iban.getNationalCheckDigit(), "0");
      });

      test("UA", () {
        final iban = IBAN("UA213223130000026007233566001");
        expect(iban.getCountry()?.countryCode, "UA");
        expect(iban.getBankCode(), "322313");
        expect(iban.getAccountNumber(), "0000026007233566001");
      });

      test("VA", () {
        final iban = IBAN("VA59001123000012345678");
        expect(iban.getCountry()?.countryCode, "VA");
        expect(iban.getBankCode(), "001");
        expect(iban.getAccountNumber(), "123000012345678");
      });

      test("VG", () {
        final iban = IBAN("VG96VPVG0000012345678901");
        expect(iban.getCountry()?.countryCode, "VG");
        expect(iban.getBankCode(), "VPVG");
        expect(iban.getAccountNumber(), "0000012345678901");
      });

      test("XK", () {
        final iban = IBAN("XK051212012345678906");
        expect(iban.getCountry()?.countryCode, "XK");
        expect(iban.getBankCode(), "12");
        expect(iban.getBranchCode(), "12");
        expect(iban.getAccountNumber(), "0123456789");
        expect(iban.getNationalCheckDigit(), "06");
      });
    });

    group("provisional countries", () {
      test("AO", () {
        final iban = IBAN("AO69123456789012345678901");
        expect(iban.getCountry()?.countryCode, "AO");
      });

      test("BF", () {
        final iban = IBAN("BF2312345678901234567890123");
        expect(iban.getCountry()?.countryCode, "BF");
      });

      test("BI", () {
        final iban = IBAN("BI41123456789012");
        expect(iban.getCountry()?.countryCode, "BI");
      });

      test("BJ", () {
        final iban = IBAN("BJ11B00610100400271101192591");
        expect(iban.getCountry()?.countryCode, "BJ");

        final iban2 = IBAN("BJ66BJ0610100100144390000769");
        expect(iban2.getCountry()?.countryCode, "BJ");
      });

      test("CF", () {
        final iban = IBAN("CF4220001000010120069700160");
        expect(iban.getCountry()?.countryCode, "CF");
      });

      test("CI", () {
        final iban = IBAN("CI93CI0080111301134291200589");
        expect(iban.getCountry()?.countryCode, "CI");
      });

      test("CM", () {
        final iban = IBAN("CM9012345678901234567890123");
        expect(iban.getCountry()?.countryCode, "CM");
      });

      test("CV", () {
        final iban = IBAN("CV30123456789012345678901");
        expect(iban.getCountry()?.countryCode, "CV");
      });

      test("DJ", () {
        final iban = IBAN("DJ2110002010010409943020008");
        expect(iban.getCountry()?.countryCode, "DJ");
      });

      test("DZ", () {
        final iban = IBAN("DZ8612345678901234567890");
        expect(iban.getCountry()?.countryCode, "DZ");
      });

      test("GQ", () {
        final iban = IBAN("GQ7050002001003715228190196");
        expect(iban.getCountry()?.countryCode, "GQ");
      });

      test("HN", () {
        final iban = IBAN("HN54PISA00000000000000123124");
        expect(iban.getCountry()?.countryCode, "HN");
      });

      test("IR", () {
        final iban = IBAN("IR861234568790123456789012");
        expect(iban.getCountry()?.countryCode, "IR");
      });

      test("MG", () {
        final iban = IBAN("MG1812345678901234567890123");
        expect(iban.getCountry()?.countryCode, "MG");
      });

      // refer https://countrywisecodes.com/mali/verify-iban-structure/ML13ML0160120102600100668497
      test("ML", () {
        final iban = IBAN("ML13ML0160120102600100668497");
        expect(iban.getCountry()?.countryCode, "ML");
      });

      test("MZ", () {
        final iban = IBAN("MZ25123456789012345678901");
        expect(iban.getCountry()?.countryCode, "MZ");
      });

      test("SN", () {
        final iban = IBAN("SN52A12345678901234567890123");
        expect(iban.getCountry()?.countryCode, "SN");
      });

      // ----
      test("KM", () {
        final iban = IBAN("KM4600005000010010904400137");
        expect(iban.getCountry()?.countryCode, "KM");
      });

      test("TD", () {
        final iban = IBAN("TD8960002000010271091600153");
        expect(iban.getCountry()?.countryCode, "TD");
      });

      test("CG", () {
        final iban = IBAN("CG3930011000101013451300019");
        expect(iban.getCountry()?.countryCode, "CG");
      });

      test("EG", () {
        final iban = IBAN("EG800002000156789012345180002");
        expect(iban.getCountry()?.countryCode, "EG");
      });

      test("GA", () {
        final iban = IBAN("GA2140021010032001890020126");
        expect(iban.getCountry()?.countryCode, "GA");
      });

      test("MA", () {
        final iban = IBAN("MA64011519000001205000534921");
        expect(iban.getCountry()?.countryCode, "MA");
      });

      test("NI", () {
        final iban = IBAN("NI92BAMC000000000000000003123123");
        expect(iban.getCountry()?.countryCode, "NI");
      });

      test("NE", () {
        final iban = IBAN("NE58NE0380100100130305000268");
        expect(iban.getCountry()?.countryCode, "NE");
      });

      test("TG", () {
        final iban = IBAN("TG53TG0090604310346500400070");
        expect(iban.getCountry()?.countryCode, "TG");
      });
    });

    group("national check digits - failures", () {
      test("NO", () {
        expect(() => IBAN("NO9386011117948"), throwsException);
      });

      test("BE", () {
        expect(() => IBAN("BE68539007547035"), throwsException);
      });

      test("FR", () {
        expect(() => IBAN("FR1420041010050500013M02607"), throwsException);
      });

      test("BJ", () {
        expect(() => IBAN("BJ66BJ0610100100144390000760"), throwsException);
      });
    });

    group("sample value", () {
      test("FR", () {
        expect(IBAN.sample("FR"), "FR1420041010050500013M02606");
      });

      test("germany as default", () {
        expect(IBAN.sample("XX"), "DE89370400440532013000");
      });
    });

    group("iban-js compatibility", () {
      test("printFormat", () {
        expect(
          IBAN.printFormat("FR1420041010050500013M02606"),
          "FR14 2004 1010 0505 0001 3M02 606",
        );
      });

      test("electronicFormat", () {
        expect(
          IBAN.electronicFormat(" FR14*2&004 1010050500013M02606*"),
          "FR1420041010050500013M02606",
        );
      });

      test("toBBAN", () {
        expect(
          IBAN.toBBAN(" FR142004 1010050500013M02606*"),
          "20041 01005 0500013M026 06",
        );
      });

      test("fromBBAN", () {
        expect(
          IBAN.fromBBAN("FR", "20041010050500013M02606"),
          "FR1420041010050500013M02606",
        );
      });

      test("isValidBBAN", () {
        expect(IBAN.isValidBBAN("FR", "20041010050500013M02606"), true);
      });
    });
  });
}
