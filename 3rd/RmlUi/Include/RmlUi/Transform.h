#pragma once

#include "Types.h"
#include "PropertyFloatValue.h"
#include <variant>
#include <glm/glm.hpp>
#include <glm/gtx/quaternion.hpp>

namespace Rml {
namespace Transforms {

struct Matrix2D : glm::mat3x2 {
	Matrix2D() : glm::mat3x2(1) {}
	Matrix2D(glm::mat3x2&& o) : glm::mat3x2(std::forward<glm::mat3x2>(o)) {}
};

struct Matrix3D : glm::mat4x4 {
	Matrix3D() : glm::mat4x4(1) {}
	Matrix3D(glm::mat4x4&& o) : glm::mat4x4(std::forward<glm::mat4x4>(o)) {}
};

struct TranslateX {
	PropertyFloatValue x = { 0.f, PropertyUnit::PX };
};

struct TranslateY {
	PropertyFloatValue y = { 0.f, PropertyUnit::PX };
};

struct TranslateZ {
	PropertyFloatValue z = { 0.f, PropertyUnit::PX };
};

struct Translate2D {
	PropertyFloatValue x = { 0.f, PropertyUnit::PX };
	PropertyFloatValue y = { 0.f, PropertyUnit::PX };
};

struct Translate3D {
	PropertyFloatValue x = { 0.f, PropertyUnit::PX };
	PropertyFloatValue y = { 0.f, PropertyUnit::PX };
	PropertyFloatValue z = { 0.f, PropertyUnit::PX };
};

struct ScaleX {
	float x = 1.f;
};

struct ScaleY {
	float y = 1.f;
};

struct ScaleZ {
	float z = 1.f;
};

struct Scale2D {
	float x = 1.f;
	float y = 1.f;
};

struct Scale3D {
	float x = 1.f;
	float y = 1.f;
	float z = 1.f;
};

struct RotateX {
	PropertyFloatValue angle = { 0.f, PropertyUnit::RAD };
};

struct RotateY {
	PropertyFloatValue angle = { 0.f, PropertyUnit::RAD };
};

struct RotateZ {
	PropertyFloatValue angle = { 0.f, PropertyUnit::RAD };
};

struct Rotate2D {
	PropertyFloatValue angle = { 0.f, PropertyUnit::RAD };
};

struct Rotate3D {
	glm::vec3 axis = glm::vec3(0, 0, 1);
	PropertyFloatValue angle = { 0.f, PropertyUnit::RAD };
};

struct SkewX {
	PropertyFloatValue x = { 0.f, PropertyUnit::RAD };
};
struct SkewY {
	PropertyFloatValue y = { 0.f, PropertyUnit::RAD };
};
struct Skew2D {
	PropertyFloatValue x = { 0.f, PropertyUnit::RAD };
	PropertyFloatValue y = { 0.f, PropertyUnit::RAD };
};
struct Perspective {
	PropertyFloatValue distance = { 0.f, PropertyUnit::PX };
};

struct DecomposedMatrix4 {
	glm::vec4 perspective = glm::vec4(0, 0, 0, 1);
	glm::quat quaternion = glm::quat(0, 0, 0, 1);
	glm::vec3 translation = glm::vec3(0, 0, 0);
	glm::vec3 scale = glm::vec3(1, 1, 1);
	glm::vec3 skew = glm::vec3(0, 0, 0);
};

inline bool operator==(const TranslateX& l, const TranslateX& r) {
	return l.x == r.x;
}
inline bool operator==(const TranslateY& l, const TranslateY& r) {
	return l.y == r.y;
}
inline bool operator==(const TranslateZ& l, const TranslateZ& r) {
	return l.z == r.z;
}
inline bool operator==(const Translate2D& l, const Translate2D& r) {
	return (l.x == r.x) && (l.y == r.y);
}
inline bool operator==(const Translate3D& l, const Translate3D& r) {
	return (l.x == r.x) && (l.y == r.y) && (l.z == r.z);
}
inline bool operator==(const ScaleX& l, const ScaleX& r) {
	return l.x == r.x;
}
inline bool operator==(const ScaleY& l, const ScaleY& r) {
	return l.y == r.y;
}
inline bool operator==(const ScaleZ& l, const ScaleZ& r) {
	return l.z == r.z;
}
inline bool operator==(const Scale2D& l, const Scale2D& r) {
	return (l.x == r.x) && (l.y == r.y);
}
inline bool operator==(const Scale3D& l, const Scale3D& r) {
	return (l.x == r.x) && (l.y == r.y) && (l.z == r.z);
}
inline bool operator==(const RotateX& l, const RotateX& r) {
	return l.angle == r.angle;
}
inline bool operator==(const RotateY& l, const RotateY& r) {
	return l.angle == r.angle;
}
inline bool operator==(const RotateZ& l, const RotateZ& r) {
	return l.angle == r.angle;
}
inline bool operator==(const Rotate2D& l, const Rotate2D& r) {
	return l.angle == r.angle;
}
inline bool operator==(const Rotate3D& l, const Rotate3D& r) {
	return (l.angle == r.angle) && (l.axis == r.axis);
}
inline bool operator==(const SkewX& l, const SkewX& r) {
	return l.x == r.x;
}
inline bool operator==(const SkewY& l, const SkewY& r) {
	return l.y == r.y;
}
inline bool operator==(const Skew2D& l, const Skew2D& r) {
	return (l.x == r.x) && (l.y == r.y);
}
inline bool operator==(const Perspective& l, const Perspective& r) {
	return l.distance == r.distance;
}
inline bool operator==(const DecomposedMatrix4& l, const DecomposedMatrix4& r) {
	return (l.perspective == r.perspective)
		&& (l.quaternion == r.quaternion)
		&& (l.translation == r.translation)
		&& (l.scale == r.scale)
		&& (l.skew == r.skew)
		;
}

using Primitive = std::variant<
	Matrix2D,
	Matrix3D,
	TranslateX,
	TranslateY,
	TranslateZ,
	Translate2D,
	Translate3D,
	ScaleX,
	ScaleY,
	ScaleZ,
	Scale2D,
	Scale3D,
	RotateX,
	RotateY,
	RotateZ,
	Rotate2D,
	Rotate3D,
	SkewX,
	SkewY,
	Skew2D,
	Perspective,
	DecomposedMatrix4
>;

}

enum class TransformType {
	Scale, Translate, Rotate, Skew, Matrix
};

struct TransformPrimitive : public Transforms::Primitive {
	template <typename T>
	TransformPrimitive(T&& v)
		: Transforms::Primitive(std::forward<T>(v))
	{}
	void   SetIdentity();
	bool   PrepareForInterpolation(Element& e);
	void   ConvertToGenericType();
	bool   Interpolate(const TransformPrimitive& other, float alpha);
	TransformType GetType() const;
	std::string ToString() const;
};

class Transform : public std::vector<TransformPrimitive> {
public:
	Transform Interpolate(const Transform& other, float alpha) const;
	glm::mat4x4 GetMatrix(Element& e) const;
	bool Combine(Element& e, size_t start);
};

}
