import 'package:flutter/material.dart';

// 앱에서 공통으로 사용되는 색상 상수 정의
const kPrimaryColor = Color(0xFF6A0DAD); // 메인 퍼플
const kSecondaryColor = Color(0xFF00D2B6); // 보조 민트
const kTextColor = Color(0xFF333333);
const kSubTextColor = Color(0xFF828282);
const kBackgroundColor = Color(0xFFF5F5F5);

// 공통으로 사용되는 텍스트 스타일
const TextStyle kHeadline1Style = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

const TextStyle kHeadline2Style = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 16,
  color: kTextColor,
);

const TextStyle kSubBodyTextStyle = TextStyle(
  fontSize: 14,
  color: kSubTextColor,
);

// 버튼 스타일
const kButtonTextStyle = TextStyle(
  fontFamily: 'Inter', // 사용 폰트
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 22 / 18, // line height
  color: Colors.white,
);

// API 기본 URL
const kApiBaseUrl = "http://15.164.216.41:8080";