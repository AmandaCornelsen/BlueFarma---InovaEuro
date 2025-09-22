class Idea {
	final int? id;
	final int userId;
	final String title;
	final String description;
	final String category;
	final int durationDays;
	final String status;
	final double progress;
	final DateTime? createdAt;
	final DateTime? updatedAt;

	Idea({
		this.id,
		required this.userId,
		required this.title,
		required this.description,
		required this.category,
		required this.durationDays,
		this.status = 'pending',
		this.progress = 0.0,
		this.createdAt,
		this.updatedAt,
	});

	factory Idea.fromMap(Map<String, dynamic> map) {
		return Idea(
			id: map['id'] as int?,
			userId: map['user_id'] as int,
			title: map['title'] as String,
			description: map['description'] as String? ?? '',
			category: map['category'] as String? ?? '',
			durationDays: map['duration_days'] as int? ?? 0,
			status: map['status'] as String? ?? 'pending',
			progress: (map['progress'] is int)
					? (map['progress'] as int).toDouble()
					: (map['progress'] as double? ?? 0.0),
			createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
			updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'user_id': userId,
			'title': title,
			'description': description,
			'category': category,
			'duration_days': durationDays,
			'status': status,
			'progress': progress,
			'created_at': createdAt?.toIso8601String(),
			'updated_at': updatedAt?.toIso8601String(),
		};
	}
}
