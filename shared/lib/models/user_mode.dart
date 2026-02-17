class UserModel {
  String id;
  SpecificationModel specification;
  String userName;
  String phone;
  bool isVerified;
  String role;
  String city;
  num age;
  num height;
  String job;
  String description;
  String language;
  bool isMarried;
  String? image;
  String gender;
  bool isEngaged;
  bool isBlocked;
  String terms;
  String note;
  bool hasMarried;
  bool allowChat;
  bool allowKhattaba;
  num randomSort;
  bool isFavorite;
  bool hasValidSubscription;


  UserModel({
    required this.id ,
    required this.specification ,
    required this.isEngaged , 
    required this.userName ,
    required this.phone ,
    required this.isVerified ,
    required this.role ,
    required this.city ,
    required this.age ,
    required this.height ,
    required this.job ,
    required this.description ,
    required this.language ,
    required this.isMarried ,
    required this.image ,
    required this.gender ,
    required this.isBlocked ,
    required this.terms ,
    required this.note ,
    required this.hasMarried ,
    required this.allowChat ,
    required this.allowKhattaba ,
    required this.randomSort ,
    required this.isFavorite ,
    required this.hasValidSubscription
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["_id"] ?? "",
        specification: SpecificationModel.fromJson(json["specification"] ?? {}),
        userName: json["userName"] ?? "",
        phone: json["phone"] ?? "",
        isVerified: json["isVerified"] ?? false,
        role: json["role"] ?? "",
        city: json["city"] ?? "",
        image: json["image"] ?? "",
        age: json["age"] ?? 0,
        height: json["height"] ?? 0,
        job: json["job"] ?? "",
        description: json["description"] ?? "",
        language: json["language"] ?? "",
        isMarried: json["isMarried"] ?? false,
        gender: json["gender"] ?? "",
        isEngaged: json["isEngaged"] ?? false,
        isBlocked: json["isBlocked"] ?? false,
        terms: json["terms"] ?? "",
        note: json["note"] ?? "",
        hasMarried: json["hasMarried"] ?? false,
        allowChat: json["allowChat"] ?? false,
        allowKhattaba: json["allowKhattaba"] ?? false,
        randomSort: json["randomSort"] ?? 0,
        isFavorite: json["isFavorite"] ?? false,
        hasValidSubscription: json["hasValidSubscription"] ?? false
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "specification": specification.toJson(),
        "userName": userName,
        "phone": phone,
        "isVerified": isVerified,
        "role": role,
        "city": city,
        "age": age,
        "height": height,
        "job": job,
        "description": description,
        "language": language,
        "isMarried": isMarried,
        "image": image,
        "gender": gender,
        "isEngaged": isEngaged,
        "isBlocked": isBlocked,
        "terms": terms,
        "note": note,
        "hasMarried": hasMarried,
        "allowChat": allowChat,
        "allowKhattaba": allowKhattaba,
        "randomSort": randomSort,
        "isFavorite": isFavorite,
        "hasValidSubscription": hasValidSubscription
      };
  UserModel copyWith({
    String? id,
    String? userName,
    String? phone,
    bool? isVerified,
    String? role,
    String? city,
    num? age,
    num? height,
    String? job,
    String? description,
    String? language,
    bool? isMarried,
    String? image,
    String? gender,
    bool? isEngaged,
    bool? isBlocked,
    String? terms,
    String? note,
    bool? hasMarried,
    bool? allowChat,
    bool? allowKhattaba,
    num? randomSort,
    bool? isFavorite,
    bool? hasValidSubscription
  }) {
    return UserModel(
      id: id ?? this.id,
      specification: specification,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      city: city ?? this.city,
      age: age ?? this.age,
      height: height ?? this.height,
      job: job ?? this.job,
      description: description ?? this.description,
      language: language ?? this.language,
      isMarried: isMarried ?? this.isMarried,
      image: image ?? this.image,
      gender: gender ?? this.gender,
      isEngaged: isEngaged ?? this.isEngaged,
      isBlocked: isBlocked ?? this.isBlocked,
      terms: terms ?? this.terms,
      note: note ?? this.note,
      hasMarried: hasMarried ?? this.hasMarried,
      allowChat: allowChat ?? this.allowChat,
      allowKhattaba: allowKhattaba ?? this.allowKhattaba,
      randomSort: randomSort ?? this.randomSort,
      isFavorite: isFavorite ?? this.isFavorite,
      hasValidSubscription: hasValidSubscription ?? this.hasValidSubscription
    );
  }
}
class SpecificationModel {
  num age;
  String beautyLevel;
  String city;
  String dowry;
  String education;
  String financialStatus;
  String hairType;
  num height;
  String job;
  String lookingFor;
  String marriageType;
  String nameEndsWith;
  String nationality;
  String skinColor;
  bool smoking;
  String terms;
  num weight;

  SpecificationModel({
    required this.age,
    required this.beautyLevel,
    required this.city,
    required this.dowry,
    required this.education,
    required this.financialStatus,
    required this.hairType,
    required this.height,
    required this.job,
    required this.lookingFor,
    required this.marriageType,
    required this.nameEndsWith,
    required this.nationality,
    required this.skinColor,
    required this.smoking,
    required this.terms,
    required this.weight,

  });

  factory SpecificationModel.fromJson(Map<String, dynamic> json) =>
      SpecificationModel(
        age: json["age"] ?? 0,
        beautyLevel: json["beautyLevel"] ?? "",
        city: json["city"] ?? "",
        dowry: json["dowry"] ?? "",
        education: json["education"] ?? "",
        financialStatus: json["financialStatus"] ?? "",
        hairType: json["hairType"] ?? "",
        height: json["height"] ?? 0,
        job: json["job"] ?? "",
        lookingFor: json["lookingFor"] ?? "",
        marriageType: json["marriageType"] ?? "",
        nameEndsWith: json["nameEndsWith"] ?? "",
        nationality: json["nationality"] ?? "",
        skinColor: json["skinColor"] ?? "",
        smoking: json["smoking"] ?? false,
        terms: json["terms"] ?? "",
        weight: json["weight"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "age": age,
    "beautyLevel": beautyLevel,
    "city": city,
    "dowry": dowry,
    "education": education,
    "financialStatus": financialStatus,
    "hairType": hairType,
    "height": height,
    "job": job,
    "lookingFor": lookingFor,
    "marriageType": marriageType,
    "nameEndsWith": nameEndsWith,
    "nationality": nationality,
    "skinColor": skinColor,
    "smoking": smoking,
    "terms": terms,
    "weight": weight,
  };
  SpecificationModel copyWith({
    num? age,
    String? beautyLevel,
    String? city,
    String? dowry,
    String? education,
    String? financialStatus,
    String? hairType,
    num? height,
    String? job,
    String? lookingFor,
    String? marriageType,
    String? nameEndsWith,
    String? nationality,
    String? skinColor,
    bool? smoking,
    String? terms,
    num? weight,
  }) {
    return SpecificationModel(
      age: age ?? this.age,
      beautyLevel: beautyLevel ?? this.beautyLevel,
      city: city ?? this.city,
      dowry: dowry ?? this.dowry,
      education: education ?? this.education,
      financialStatus: financialStatus ?? this.financialStatus,
      hairType: hairType ?? this.hairType,
      height: height ?? this.height,
      job: job ?? this.job,
      lookingFor: lookingFor ?? this.lookingFor,
      marriageType: marriageType ?? this.marriageType,
      nameEndsWith: nameEndsWith ?? this.nameEndsWith,
      nationality: nationality ?? this.nationality,
      skinColor: skinColor ?? this.skinColor,
      smoking: smoking ?? this.smoking,
      terms: terms ?? this.terms,
      weight: weight ?? this.weight,
    );
  }
}
