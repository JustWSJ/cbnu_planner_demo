// 통합된 단일 코드 - main.dart 하나로 모든 기능 포함

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CBNUPlannerApp());
}

class CBNUPlannerApp extends StatelessWidget {
  const CBNUPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CBNU Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ScheduleInputPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Schedule {
  final String title;
  final String place;
  final TimeOfDay time;

  Schedule({required this.title, required this.place, required this.time});

  Map<String, dynamic> toJson() => {
        'title': title,
        'place': place,
        'hour': time.hour,
        'minute': time.minute,
      };

  static Schedule fromJson(Map<String, dynamic> json) => Schedule(
        title: json['title'],
        place: json['place'],
        time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      );
}

class Building {
  final String name;
  final LatLng location;
  Building({required this.name, required this.location});
}

class ScheduleInputPage extends StatefulWidget {
  const ScheduleInputPage({super.key});

  @override
  State<ScheduleInputPage> createState() => _ScheduleInputPageState();
}

class _ScheduleInputPageState extends State<ScheduleInputPage> {
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay? _selectedTime;
  String? _selectedBuilding;
  final List<Schedule> _schedules = [];

  final List<Building> buildingList = [
    Building(name: "수위실(N1)", location: LatLng(0.0, 0.0)), // N1
    Building(name: "법학전문대학원(N2)", location: LatLng(0.0, 0.0)), // N2
    Building(name: "테니스장 관리실(N3)", location: LatLng(0.0, 0.0)), // N3
    Building(name: "산학협력관(N4)", location: LatLng(0.0, 0.0)), // N4
    Building(name: "평생교육원(N5)", location: LatLng(0.0, 0.0)), // N5
    Building(name: "고시원(N6)", location: LatLng(0.0, 0.0)), // N6
    Building(name: "형설관(N7)", location: LatLng(0.0, 0.0)), // N7
    Building(name: "보육교사교육원(N8)", location: LatLng(0.0, 0.0)), // N8
    Building(name: "언어교육관,보육교사교육원(N9)", location: LatLng(0.0, 0.0)), // N9
    Building(name: "대학 본부,국제교류원(N10)", location: LatLng(0.0, 0.0)), // N10
    Building(name: "공동실험실습관(N11)", location: LatLng(0.0, 0.0)), // N11
    Building(name: "중앙도서관(N12)", location: LatLng(0.0, 0.0)), // N12
    Building(name: "경영학관(N13)", location: LatLng(0.0, 0.0)), // N13
    Building(name: "인문사회관(강의동)(N14)", location: LatLng(0.0, 0.0)), // N14
    Building(name: "사회과학대학본관(N15)", location: LatLng(0.0, 0.0)), // N15
    Building(name: "인문대학본관(N16-1)", location: LatLng(0.0, 0.0)), // N16-1
    Building(name: "미술관(N16-2)", location: LatLng(0.0, 0.0)), // N16-2
    Building(name: "미술과(N16-3)", location: LatLng(0.0, 0.0)), // N16-3
    Building(name: "개성재(수위실)(N17-1)", location: LatLng(0.0, 0.0)), // N17-1
    Building(name: "개성재 관리동(N17-2)", location: LatLng(0.0, 0.0)), // N17-2
    Building(name: "개성재(진리관)(N17-3)", location: LatLng(0.0, 0.0)), // N17-3
    Building(name: "개성재(정의관)(N17-4)", location: LatLng(0.0, 0.0)), // N17-4
    Building(name: "개성재(개척관)(N17-5)", location: LatLng(0.0, 0.0)), // N17-5
    Building(name: "계영원(N17-6)", location: LatLng(0.0, 0.0)), // N17-6
    Building(name: "법학관(N18)", location: LatLng(0.0, 0.0)), // N18
    Building(name: "제2본관(N19)", location: LatLng(0.0, 0.0)), // N19
    Building(name: "생활과학관(N20-1)", location: LatLng(0.0, 0.0)), // N20-1
    Building(name: "생활과학대학부설ㆍ보육교사교육원어린이집(N20-2)", location: LatLng(0.0, 0.0)), // N20-2
    Building(name: "은하수식당(N21)", location: LatLng(0.0, 0.0)), // N21
    Building(name: "사범대학실험동(E1-1)", location: LatLng(0.0, 0.0)), // E1-1
    Building(name: "사범대학강의동(E1-2)", location: LatLng(0.0, 0.0)), // E1-2
    Building(name: "개신문화관(E2)", location: LatLng(0.0, 0.0)), // E2
    Building(name: "제1학생회관(E3)", location: LatLng(0.0, 0.0)), // E3
    Building(name: "NH관(E3-1)", location: LatLng(0.0, 0.0)), // E3-1
    Building(name: "실내체육관(E4-1)", location: LatLng(0.0, 0.0)), // E4-1
    Building(name: "운동장본부석(E4-2)", location: LatLng(0.0, 0.0)), // E4-2
    Building(name: "보조체육관(E4-3)", location: LatLng(0.0, 0.0)), // E4-3
    Building(name: "123학군단(E5)", location: LatLng(0.0, 0.0)), // E5
    Building(name: "특고변전실(E6)", location: LatLng(0.0, 0.0)), // E6
    Building(name: "의과대학(E7-1)", location: LatLng(0.0, 0.0)), // E7-1
    Building(name: "임상 연구동(E7-2)", location: LatLng(0.0, 0.0)), // E7-2
    Building(name: "의과대학2호관(E7-3)", location: LatLng(0.0, 0.0)), // E7-3
    Building(name: "공학관(E8-1)", location: LatLng(0.0, 0.0)), // E8-1
    Building(name: "합동강의실(E8-2)", location: LatLng(0.0, 0.0)), // E8-2
    Building(name: "건설공학관(E8-3)", location: LatLng(0.0, 0.0)), // E8-3
    Building(name: "제1공장동(E8-4)", location: LatLng(0.0, 0.0)), // E8-4
    Building(name: "제2공장동(E8-5)", location: LatLng(0.0, 0.0)), // E8-5
    Building(name: "토목공학관(E8-6)", location: LatLng(0.0, 0.0)), // E8-6
    Building(name: "공대공학관(E8-7)", location: LatLng(0.0, 0.0)), // E8-7
    Building(name: "공학지원센터(E8-8)", location: LatLng(0.0, 0.0)), // E8-8
    Building(name: "신소재재료실험실(E8-9)", location: LatLng(0.0, 0.0)), // E8-9
    Building(name: "제5공학관(E8-10)", location: LatLng(0.0, 0.0)), // E8-10
    Building(name: "학연산공동기술연구원(E9)", location: LatLng(0.0, 0.0)), // E9
    Building(name: "학연산공동 교육관(E10)", location: LatLng(0.0, 0.0)), // E10
    Building(name: "목장창고", location: LatLng(0.0, 0.0)), // E11-1
    Building(name: "우사", location: LatLng(0.0, 0.0)), // E11-2
    Building(name: "목장관리사", location: LatLng(0.0, 0.0)), // E11-3
    Building(name: "건조창고", location: LatLng(0.0, 0.0)), // E11-4
    Building(name: "동물자원연구지원센터", location: LatLng(0.0, 0.0)), // E11-5
    Building(name: "수의과대학2호관", location: LatLng(0.0, 0.0)), // E12-2
    Building(name: "수의과대학및동물의료센터", location: LatLng(0.0, 0.0)), // E12-1
    Building(name: "실험동물연구지원센터", location: LatLng(0.0, 0.0)), // E12-3
    Building(name: "자연과학대학본관(S1-1)", location: LatLng(36.627764, 127.456824)), // S1-1
    Building(name: "자연대2호관(S1-2)", location: LatLng(36.627166, 127.456904)), // S1-2
    Building(name: "자연대3호관(S1-3)", location: LatLng(36.626701, 127.456850)), // S1-3
    Building(name: "자연대4호관(S1-4)", location: LatLng(36.626313, 127.456861)), // S1-4
    Building(name: "자연대5호관(S1-5)", location: LatLng(36.625513, 127.455499)), // S1-5
    Building(name: "자연대6호관(S1-6)", location: LatLng(36.624871, 127.455906)), // S1-6
    Building(name: "과학기술도서관(S1-7)", location: LatLng(36.626946, 127.457084)), // S1-7
    Building(name: "전산정보원(S2)", location: LatLng(36.626396, 127.455397)), // S2
    Building(name: "본부관리동(S3)", location: LatLng(36.626473, 127.454495)), // S3
    Building(name: "약학대학본관(S4-1)", location: LatLng(36.625625, 127.454415)), // S4-1
    Building(name: "약학연구동(S4-2)", location: LatLng(36.625254, 127.454823)), // S4-2
    Building(name: "농장관리실(S5-1)", location: LatLng(36.625095, 127.453777)), // S5-1
    Building(name: "농장관리실창고(S5-2)", location: LatLng(36.624927, 127.453739)), // S5-2
    Building(name: "자연대온실 1(S6-1)", location: LatLng(36.625781, 127.453331)), // S6-1
    Building(name: "자연대온실 2(S6-2)", location: LatLng(36.626662, 127.453144)), // S6-2
    Building(name: "에너지저장연구센터(S7-1)", location: LatLng(36.626020, 127.453830)), // S7-1
    Building(name: "교육대학원, 동아리방(S7-2)", location: LatLng(36.626533, 127.453664)), // S7-2
    Building(name: "야외공연장(S8)", location: LatLng(36.626821, 127.453959)), // S8
    Building(name: "박물관(S9)", location: LatLng(36.627721, 127.455263)), // S9
    Building(name: "차고(S10)", location: LatLng(36.627994, 127.455552)), // S10
    Building(name: "유류저장창고(S11)", location: LatLng(36.627859, 127.455576)), // S11
    Building(name: "쓰레기 처리장(S12)", location: LatLng(36.628321, 127.455013)), // S12
    Building(name: "목공실(S13)", location: LatLng(36.628110, 127.454630)), // S13
    Building(name: "제2학생회관(S14)", location: LatLng(36.628027, 127.454326)), // S14
    Building(name: "제1본관(S15)", location: LatLng(0.0, 0.0)), // S15
    Building(name: "본부 창고(S16)", location: LatLng(0.0, 0.0)), // S16
    Building(name: "양성재(지선관)(S17-1)", location: LatLng(36.628061, 127.452704)), // S17-1
    Building(name: "양성재(명덕관(S17-2)", location: LatLng(36.628061, 127.452704)), // S17-2
    Building(name: "양성재(신민관)(S17-3)", location: LatLng(36.627192, 127.452221)), // S17-3
    Building(name: "양현재(수위실)(S17-4)", location: LatLng(36.627587, 127.450118)), // S17-4
    Building(name: "양현재(청운관)(S17-5)", location: LatLng(36.627760, 127.450140)), // S17-5
    Building(name: "양현재(등용관)(S17-6)", location: LatLng(36.627097, 127.451011)), // S17-6
    Building(name: "양현재(관리동)(S17-7)", location: LatLng(36.626998, 127.450496)), // S17-7
    Building(name: "승리관(운동부합숙소)(S18)", location: LatLng(36.628538, 127.451448)), // S18
    Building(name: "종양 연구소(S19)", location: LatLng(36.628776, 127.451749)), // S19
    Building(name: "첨단바이오 연구센터(S20)", location: LatLng(36.628883, 127.452435)), // S20
    Building(name: "농업전문창업보육센터(S21-1)", location: LatLng(36.628875, 127.453042)), // S21-1
    Building(name: "임산가공공장(S21-2)", location: LatLng(36.629309, 127.451465)), // S21-2
    Building(name: "농업과학기술센터(S21-3)", location: LatLng(36.629521, 127.451663)), // S21-3
    Building(name: "농학관 강의동(S21-4)", location: LatLng(36.629443, 127.452666)), // S21-4
    Building(name: "농학관 실험동(S21-5)", location: LatLng(36.630033, 127.453267)), // S21-5
    Building(name: "건조실(S21-6)", location: LatLng(36.629998, 127.451797)), // S21-6
    Building(name: "온실(특용식물학과)(S21-7)", location: LatLng(36.630095, 127.451862)), // S21-7
    Building(name: "온실(식물자원학과)(S21-8)", location: LatLng(36.630033, 127.451993)), // S21-8
    Building(name: "온실(식물의학과)(S21-9)", location: LatLng(36.630267, 127.452022)), // S21-9
    Building(name: "온실(산림학과)(S21-10)", location: LatLng(36.630192, 127.452132)), // S21-10
    Building(name: "온실(원예과학과)(S21-11)", location: LatLng(36.630429, 127.452146)), // S21-11
    Building(name: "온실(원예과학과)(S21-12)", location: LatLng(36.630347, 127.452234)), // S21-12
    Building(name: "온실창고(S21-13)", location: LatLng(36.630274, 127.451548)), // S21-13
    Building(name: "온실(1)(S21-14)", location: LatLng(36.630517, 127.451580)), // S21-14
    Building(name: "온실(2)(S21-15)", location: LatLng(36.630517, 127.451580)), // S21-15
    Building(name: "온실(3)(S21-16)", location: LatLng(36.630517, 127.451580)), // S21-16
    Building(name: "온실(4)(S21-17)", location: LatLng(36.630517, 127.451580)), // S21-17
    Building(name: "온실(5)(S21-18)", location: LatLng(36.630517, 127.451580)), // S21-18
    Building(name: "넷트하우스(S21-19)", location: LatLng(36.630812, 127.451247)), // S21-19
    Building(name: "온실관리동(S21-20)", location: LatLng(36.630678, 127.451749)), // S21-20
    Building(name: "동위원소실(S21-21)", location: LatLng(36.630571, 127.452256)), // S21-21
    Building(name: "농기계공작실(S21-22)", location: LatLng(36.631096, 127.451904)), // S21-22
    Building(name: "농기계실습실(S21-23)", location: LatLng(36.630894, 127.452151)), // S21-23
    Building(name: "농대부속건물(S21-24)", location: LatLng(36.630773, 127.452382)), // S21-24
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submitSchedule() {
    if (_titleController.text.isEmpty || _selectedBuilding == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요')));
      return;
    }
    final newSchedule = Schedule(
      title: _titleController.text,
      place: _selectedBuilding!,
      time: _selectedTime!,
    );
    setState(() {
      _schedules.add(newSchedule);
      _titleController.clear();
      _selectedTime = null;
      _selectedBuilding = null;
    });
    _saveSchedules();
  }

  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_schedules.map((s) => s.toJson()).toList());
    await prefs.setString('schedules', encoded);
  }

  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('schedules');
    if (raw != null) {
      final decoded = jsonDecode(raw);
      final loaded = (decoded as List).map((e) => Schedule.fromJson(e)).toList();
      setState(() => _schedules.addAll(loaded));
    }
  }

  void _clearSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('schedules');
    setState(() => _schedules.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일정 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '일정 제목'),
            ),
            DropdownButton<String>(
              hint: const Text('건물 선택'),
              value: _selectedBuilding,
              items: buildingList.map((b) => DropdownMenuItem(value: b.name, child: Text(b.name))).toList(),
              onChanged: (value) => setState(() => _selectedBuilding = value),
            ),
            Row(
              children: [
                ElevatedButton(onPressed: _pickTime, child: const Text('시간 선택')),
                const SizedBox(width: 16),
                Text(_selectedTime != null ? _selectedTime!.format(context) : '시간 미선택'),
              ],
            ),
            ElevatedButton(onPressed: _submitSchedule, child: const Text('일정 추가')),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapRoutePage(schedules: _schedules, buildingList: buildingList),
                ),
              ),
              child: const Text('경로 보기'),
            ),
            ElevatedButton(onPressed: _clearSchedules, child: const Text('초기화')),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  final s = _schedules[index];
                  return ListTile(title: Text('${s.title} (${s.place}) - ${s.time.format(context)}'));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MapRoutePage extends StatefulWidget {
  final List<Schedule> schedules;
  final List<Building> buildingList;

  const MapRoutePage({super.key, required this.schedules, required this.buildingList});

  @override
  State<MapRoutePage> createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() => currentLocation = LatLng(pos.latitude, pos.longitude));
    }
  }

  List<LatLng> _getRoutePoints() {
    final points = widget.schedules.map((s) {
      final b = widget.buildingList.firstWhere((b) => b.name == s.place, orElse: () => Building(name: '', location: LatLng(0, 0)));
      return (b.location.latitude != 0 && b.location.longitude != 0) ? b.location : null;
    }).whereType<LatLng>().toList();
    if (currentLocation != null) points.insert(0, currentLocation!);
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final points = _getRoutePoints();
    return Scaffold(
      appBar: AppBar(title: const Text('경로 보기')),
      body: FlutterMap(
        options: MapOptions(center: points.isNotEmpty ? points.first : LatLng(36.6282, 127.4562), zoom: 17.0),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.cbnu_planner',
          ),
          if (points.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(points: points, strokeWidth: 4.0, color: Colors.blueAccent),
              ],
            ),
          MarkerLayer(
            markers: points
                .map((p) => Marker(
                      point: p,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
