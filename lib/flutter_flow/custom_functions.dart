import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import '../backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/auth_util.dart';

int transportActionsCO2e(
  String distance,
  String passengers,
  String powertype,
  String transport,
  bool roundTrip,
) {
  double co2e = 0;
  int dist = int.parse(distance);
  var passengersInt = int.parse(passengers);

  if (transport == "car") {
    // powertype : CO2 per Km
    // Default is Thermic
    double co2powertype = 193;
    switch (powertype) {
      case "Thermique":
        co2powertype = 193;
        break;
      case "Électrique":
        co2powertype = 19.8;
        break;
      case "Hybride":
        co2powertype = 50;
        break;
    }

    // Co2 is distance * co2 per km for powertype * ratio of ownership / nomber of passengers
    co2e = (dist * co2powertype) / passengersInt;
  }

  // Bike
  else if (transport == "bike") {
    // powertype : CO2 per Km
    // Default is Classic
    double co2powertype = 0;
    switch (powertype) {
      case "Classique":
        co2powertype = 0;
        break;
      case "Électrique":
        co2powertype = 2;
        break;
    }
    co2e = dist * co2powertype;
  }

  // Moto
  else if (transport == "moto") {
    double co2perkm = 168;
    co2e = dist * co2perkm;
  }

  // Flight
  else if (transport == "flight") {
    double co2perkm = 82.8;
    co2e = dist * co2perkm;
  }

  // Metro
  else if (transport == "metro") {
    // 2.5 gCo2e / km (Paris)
    // Distance is not KM but number of stations
    // ~0.57 Km between 2 stations (Paris)
    double co2perkm = 2.5;
    double distanceBetweenTwoStations = 0.570;
    co2e = dist * co2perkm * distanceBetweenTwoStations;
  }

  // TGV (High Speed Train)
  else if (transport == "train") {
    double co2perkm = 24.8; // Default TER
    switch (powertype) {
      case "TGV":
        co2perkm = 1.73;
        break;
      case "TER":
        co2perkm = 24.8;
        break;
      case "intercites":
        co2perkm = 5.29;
        break;
      case "RER":
        co2perkm = 4.1;
        break;
      case "transilien":
        co2perkm = 4.1;
        break;
      case "tramway":
        co2perkm = 2.2;
        break;
    }
    co2e = dist * co2perkm;
  }

  // Train bus
  else if (transport == "bus") {
    double co2perkm = 103;

    switch (powertype) {
      case "Thermique":
        co2perkm = 103;
        break;
      case "Électrique":
        co2perkm = 9.5;
        break;
      case "Gaz Naturel":
        co2perkm = 113;
        break;
    }
    co2e = dist * co2perkm;
  } else if (transport == "scooter") {
    // powertype : CO2 per Km
    // Default is Thermic
    double co2powertype = 61.6;
    switch (powertype) {
      case "Thermique":
        co2powertype = 61.6;
        break;
      case "Électrique":
        co2powertype = 4.1;
        break;
    }

    // Co2 is distance * co2 per km for powertype * ratio of ownership / nomber of passengers
    co2e = (dist * co2powertype) / passengersInt;
  }

  // If roundTrip is Truc, co2e is *2
  if (roundTrip) {
    co2e = co2e * 2;
  }

  return co2e.round();
}

String printScore(int score) {
  String co2 = "0";
  String unit = "g";

  if (score < 1000) {
    co2 = score.toString();
    unit = "g";
  } else if (score >= 1000 && score < 10000) {
    co2 = (score / 1000).toStringAsFixed(2);
    unit = "kg";
  } else if (score >= 10000 && score < 20000) {
    co2 = (score / 1000).toStringAsFixed(1);
    unit = "kg";
  } else if (score >= 20000 && score < 1000000) {
    co2 = (score / 1000).toStringAsFixed(0);
    unit = "kg";
  } else if (score >= 1000000) {
    co2 = (score / 1000000).toStringAsFixed(2);
    unit = "T";
  }
  return co2 + " " + unit;
}

int energyPeriodicsCO2e(
  String energy,
  String volume,
  String powertype,
  String peopleSharing,
) {
  double co2e = 0;
  int vol = int.parse(volume);
  int peopleSharingInt = int.parse(peopleSharing);

  // Electricity
  if (energy == "electricity") {
    // powertype : CO2 per KWH
    // Default is Nuclear
    double co2powertype = 6;
    switch (powertype) {
      case "Nucléaire":
        co2powertype = 6;
        break;
      case "Éolienne (mer)":
        co2powertype = 9;
        break;
      case "Éolienne (terre)":
        co2powertype = 10;
        break;
      case "Hydroélectrique":
        co2powertype = 10;
        break;
      case "Biomasse":
        co2powertype = 32;
        break;
      case "Géothermique":
        co2powertype = 38;
        break;
      case "Fioul":
        co2powertype = 730;
        break;
      case "Charbon":
        co2powertype = 1058;
        break;
    }

    // Co2 volume * gCo2z/volume dividied by the number of people in the house
    co2e = (vol * co2powertype) / peopleSharingInt / 365;
  }

  // Gas
  else if (energy == "gas") {
    // powertype : CO2 per KWH
    // Default is Natural
    double co2powertype = 239;
    switch (powertype) {
      case "Gaz naturel":
        co2powertype = 239;
        break;
      case "Gaz de cokerie":
        co2powertype = 171;
        break;
      case "Gaz de haut fourneau":
        co2powertype = 968;
        break;
    }
    co2e = (vol * co2powertype) / peopleSharingInt / 365;
  }

  // Water
  else if (energy == "water") {
    double co2PerM3 = 394;
    co2e = (vol * co2PerM3) / peopleSharingInt / 365;
  }

  return co2e.round();
}

int foodActionsCO2e(
  String food,
  String mainComponents,
  List<String> sideComponents,
  int portions,
) {
  double co2e = 0.0;

  // FRUITS & SEEDS
  // Fruit : 0.27 g.co2e / g | 85g / portion
  double co2eFruit = 0.27 * 85;
  // Transformed fruit (compote) : 0.68 g.co2e / g | 85g  / portion
  double co2eTransformedFruit = 0.68 * 85;
  // Seed : 1.33 g.co2e / g |  40g / portion
  double co2eSeed = 1.33 * 40;

  // PROTEIN
  // Fish : 6.18 g.co2e / g | 110g / portion
  double co2eFish = 6.18 * 110;
  // Shellfish : 10.7 g.co2e / g | 110g / portion
  double co2eShellfish = 10.7 * 110;
  // Egg : 2.61 g.co2e / g | 50g / portion
  double co2eEgg = 2.61 * 50;
  // Meat : 21.78 g.co2e / g | 110g / portion
  double co2eMeat = 21.78 * 110;
  // Poultry : 5.91 g.co2e / g | 110g / portion
  double co2ePoultry = 5.91 * 110;
  // Deli : 7 g.co2e / g | 110g / portion
  double co2eDeli = 7.0 * 110;
  // Offal : 7.36 g.co2e / g | 110g / portion
  double co2eOffal = 7.36 * 110;

  // VEGETABLES / CEREALS / STARCHES
  // Breakfast cereals : 0.34 g.co2e / g | 80g / portion
  double co2eBreakfastCereals = 0.34 * 80;
  // Rice / Pasta / Wheat / Cereals : 0.71 g.co2e / g | 170g / portion
  double co2eRicePastaWheat = 0.71 * 170;
  // Legume (beans, because) : 0.79 g.co2e / g | 70g / portion
  double co2eLegume = 0.79 * 70;
  // Potatoes : 0.60 g.co2e / g | 170g / portion
  double co2ePotatoes = 0.60 * 170;
  // Vegetables : 1.29 g.co2e / g | 250g / portion
  double co2eVegetables = 1.29 * 250;

  // DAIRY
  // Glass of milk : 1.22 g.co2e / g | 250g / portion
  double co2eGlassMilk = 1.22 * 250;
  // Yogurt : 2.88 g.co2e / g | 100g / portion
  double co2eYogurt = 2.88 * 100;
  // Cheese  : 4.94 g.co2e / g | 30g / portion
  double co2eCheese = 4.94 * 30;

  // DESERT / CAKE
  // Cake / Pastry : 2.87 g.co2e / g | 40g / portion
  double co2eCakePastry = 2.87 * 40;
  // Icecream : 2.81 g.co2e / g | 50g / portion
  double co2eIcecream = 2.81 * 50;
  // Custard  : 1.51 g.co2e / g | 100g / portion
  double co2eCustard = 1.51 * 100;
  // Chocolate / Sweets  : 5.63 g.co2e / g |  ?

  // DRINKS
  // Bottle of Water  : 0.40 g.co2e / g | 250g / portion
  double co2eBottleWater = 0.40 * 250;
  // Tap Water : 0 g.co2e / g | 250g / portion
  double co2eTapWater = 0.0 * 250;
  // Fruit juice  : 1.90 g.co2e / g | 250g / portion
  double co2eFruitJuice = 1.90 * 250;
  // Soup : 0.95 g.co2e / g | 250g / portion
  double co2eSoup = 0.95 * 250;
  // Alcohol : 2.05 g.co2e / g | 250g / portion
  double co2eAlcohol = 2.05 * 250;
  // Hot drink  : 1.34 g.co2e / g | 250g / portion
  double co2eHotDrink = 1.34 * 250;
  // Soda : 1.34 g.co2e / g | 170g  / canette
  double co2eSoda = 170;

  // Bread
  // Bread  : 1.52 g.co2e / g | 50g / portion
  double co2eBread = 1.52 * 50;

  // Coffee
  // http://www.bco2.fr/dt_cafe_875.htm 1 cup per day un g
  double co2eCoffeeFilter = 57;
  double co2eCoffeeExpresso = 44;
  double co2eCoffeeCapsule = 74;

  // JUNK FOOD needs portions

  if (food == "starter") {
    switch (mainComponents) {
      case "Végétarienne":
        co2e += 75;
        break;
      case "Mixte":
        co2e += 150;
        break;
      case "Viande":
        co2e += 300;
        break;
    }
  } else if (food == "main") {
    double co2eMain = 0.0;
    double co2eSide = 0.0;

    for (var i = 0; i < sideComponents.length; i++) {
      String currentSideComponents = sideComponents[i];
      switch (currentSideComponents) {
        case "Riz":
          co2eSide += co2eRicePastaWheat;
          break;
        case "Pâtes":
          co2eSide += co2eRicePastaWheat;
          break;
        case "Blé":
          co2eSide += co2eRicePastaWheat;
          break;
        case "Légumes":
          co2eSide += co2eVegetables;
          break;
        case "Pommes de terre":
          co2eSide += co2ePotatoes;
          break;
      }
    }

    // Divide by number of components
    co2eSide = co2eSide / (sideComponents.length);

    switch (mainComponents) {
      case "Oeuf":
        co2eMain += co2eEgg;
        break;
      case "Poisson":
        co2eMain += co2eFish;
        break;
      case "Viande rouge":
        co2eMain += co2eMeat;
        break;
      case "Viande blanche":
        co2eMain += co2ePoultry;
        break;
      case "Végétarien":
        co2eMain += co2e * 2;
        break;
    }

    // Divide by number of components
    co2e = co2eMain + co2eSide;
  } else if (food == "desert") {
    switch (mainComponents) {
      case "Fruits":
        co2e += co2eFruit;
        break;
      case "Fruits transformés":
        co2e += co2eTransformedFruit;
        break;
      case "Yaourt":
        co2e += co2eYogurt;
        break;
      case "Pâtisserie":
        co2e += co2eCakePastry;
        break;
      case "Glace":
        co2e += co2eIcecream;
        break;
      case "Crême dessert":
        co2e += co2eCustard;
        break;
    }
  } else if (food == "drinks") {
    switch (mainComponents) {
      case "Eau en bouteille":
        co2e += co2eBottleWater;
        break;
      case "Eau du robinet":
        co2e += co2eTapWater;
        break;
      case "Jus de fruit":
        co2e += co2eFruitJuice;
        break;
      case "Soupe":
        co2e += co2eSoup;
        break;
      case "Alcool":
        co2e += co2eAlcohol;
        break;
      case "Boisson chaude":
        co2e += co2eHotDrink;
        break;
      case "Soda":
        co2e += co2eSoda;
        break;
    }
  } else if (food == "cheese") {
    co2e += co2eCheese;
  } else if (food == "bread") {
    co2e += co2eBread;
  } else if (food == "coffee") {
    switch (mainComponents) {
      case "Café filtre":
        co2e += co2eCoffeeFilter;
        break;
      case "Expresso":
        co2e += co2eCoffeeExpresso;
        break;
      case "Capsule":
        co2e += co2eCoffeeCapsule;
        break;
    }
  }

  // Breakfast

  // Portions
  co2e = co2e * portions;

  return co2e.round();
}

String timestampToDay(DateTime timestamp) {
  // Add your function code here!
  var formatter = DateFormat('d/M/y');
  String formattedDate = formatter.format(timestamp);
  //return DateTime.parse(formattedDate); // change to 25/7/2022
  return formattedDate;
}

String setOneDayBefore(String activeDate) {
  var parsedDate = DateFormat('d/M/y').parse(activeDate);
  DateTime oneDayAgo = parsedDate.subtract(new Duration(days: 1));
  String formattedDate = DateFormat('d/M/y').format(oneDayAgo);

  return formattedDate;
}

String setOneDayAfter(String activeDate) {
  var parsedDate = DateFormat('d/M/y').parse(activeDate);
  DateTime oneDayAfter = parsedDate.add(new Duration(days: 1));
  String formattedDate = DateFormat('d/M/y').format(oneDayAfter);

  return formattedDate;
}

double ratioScoreTotal(
  int score,
  int total,
) {
  // Add your function code here!
  var ratio = (score / total);
  if (ratio > 1) {
    ratio = 1;
  }
  var output = ratio.toStringAsFixed(2);
  return double.parse(output);
}

String printRatioScoreTotal(
  int score,
  int total,
) {
  if (total == 0) {
    total = 1; // No divide by zero
  }

  // Add your function code here!
  var ratio = 100 * (score / total);
  var val = ratio.toStringAsFixed(0);
  var unit = '%';
  return val + " " + unit;
}

List<String> getTransportPowerType(String transport) {
  List<String> params = [];

  switch (transport) {
    case "car":
      params.add('Thermique');
      params.add('Hybride');
      params.add('Électrique');
      break;
    case "bus":
      params.add('Thermique');
      params.add('Gaz Naturel');
      params.add('Électrique');
      break;
    case "scooter":
      params.add('Thermique');
      params.add('Électrique');
      break;
    case "train":
      params.add('TGV');
      params.add('TER');
      params.add('intercites');
      params.add('RER');
      params.add('transilien');
      params.add('tramway');
      break;
    case "bike":
      params.add('Classique');
      params.add('Électrique');
      break;
    case "flight":
      params.add('Avion commercial');
      break;
    case "metro":
      params.add('RATP');
      break;
    case "moto":
      params.add('Thermique');
      params.add('Électrique');
      break;
  }

  return params;
}

List<String> getEnergyPowertype(String energy) {
  List<String> params = [];

  switch (energy) {
    case "electricity":
      params.add('Nucléaire');
      params.add('Éolienne (mer)');
      params.add('Éolienne (terre)');
      params.add('Hydroélectrique');
      params.add('Biomasse');
      params.add('Géothermique');
      params.add('Fioul');
      params.add('Charbon');
      break;
    case "gas":
      params.add('Gaz naturel');
      params.add('Gaz de cokerie');
      params.add('Gaz de haut fourneau');
      break;
    case "water":
      params.add('Circuit France');
      break;
  }

  return params;
}

List<String> getFoodMainComponents(String food) {
  List<String> params = [];

  switch (food) {
    case "starter":
      params.add('Végétarienne');
      params.add('Mixte');
      params.add('Viande');
      break;
    case "main":
      params.add('Végétarien');
      params.add('Oeuf');
      params.add('Poisson');
      params.add('Viande rouge');
      params.add('Viande blanche');
      break;
    case "desert":
      params.add('Fruits');
      params.add('Fruits transformés');
      params.add('Yaourt');
      params.add('Pâtisserie');
      params.add('Glace');
      params.add('Crême dessert');
      break;
    case "drinks":
      params.add('Eau en bouteille');
      params.add('Eau du robinet');
      params.add('Jus de fruit');
      params.add('Soupe');
      params.add('Alcool');
      params.add('Boisson chaude');
      params.add('Soda');
      break;
    case "coffee":
      params.add('Café filtre');
      params.add('Expresso');
      params.add('Capsule');
      break;
  }

  return params;
}

List<String> getFoodSideComponents(String food) {
  List<String> params = [];

  switch (food) {
    case "main":
      params.add('Riz');
      params.add('Pâtes');
      params.add('Blé');
      params.add('Légumes');
      params.add('Pommes de terre');
      break;
  }

  return params;
}

List<String> getTransportPassengers(String transport) {
  List<String> params = [];

  switch (transport) {
    case "car":
      params.add('1');
      params.add('2');
      params.add('3');
      params.add('4');
      params.add('5');
      params.add('6');
      params.add('7');
      params.add('8');
      break;
    case "bus":
      params.add('Non applicable');
      break;
    case "scooter":
      params.add('1');
      params.add('2');
      break;
    case "train":
      params.add('Non applicable');
      break;
    case "bike":
      params.add('1');
      params.add('2');
      break;
    case "flight":
      params.add('Non applicable');
      break;
    case "metro":
      params.add('Non applicable');
      break;
    case "moto":
      params.add('1');
      params.add('2');
      break;
  }

  return params;
}

String getTransportDistanceLabel(String transport) {
  String label = "";

  switch (transport) {
    case "car":
      label = "Distance parcourue (en KMs)";
      break;
    case "bus":
      label = "Nombre de stations";
      break;
    case "scooter":
      label = "Distance parcourue (en KMs)";
      break;
    case "train":
      label = "Distance parcourue (en KMs)";
      break;
    case "bike":
      label = "Distance parcourue (en KMs)";
      break;
    case "flight":
      label = "Distance parcourue (en KMs)";
      break;
    case "metro":
      label = "Nombre de stations";
      break;
    case "moto":
      label = "Distance parcourue (en KMs)";
      break;
  }

  return label;
}

String getEnergyVolumeLabel(String energy) {
  String label = "";

  switch (energy) {
    case "electricity":
      label = "Consommation annuelle en KWH";
      break;
    case "gas":
      label = "Consommation annuelle en KWH";
      break;
    case "water":
      label = "Consommation annuelle en M3";
      break;
  }

  return label;
}

int getActiveScore(
  List<int> scores,
  int dayRelative,
) {
  return scores[dayRelative];
}

String printRank(int rank) {
  // Rank starts at 0
  var newRank = rank + 1;
  var newRankString = "#" + newRank.toString();
  return newRankString;
}
