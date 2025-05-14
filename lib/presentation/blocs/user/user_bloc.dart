import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/repositories/badge_repository.dart';
import '../../../data/models/badge_model.dart';
import '../../../core/error/failures.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final QuizRepository _quizRepository;
  final BadgeRepository _badgeRepository;

  UserBloc({
    required UserRepository userRepository,
    required QuizRepository quizRepository,
    required BadgeRepository badgeRepository,
  })  : _userRepository = userRepository,
        _quizRepository = quizRepository,
        _badgeRepository = badgeRepository,
        super(const UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<LoadUserStats>(_onLoadUserStats);
    on<UpdateUserPoints>(_onUpdateUserPoints);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      final userResult = await _userRepository.getUserById(event.userId);
      
      await userResult.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(UserError(failure.toString()));
          }
        },
        (user) async {
          // Get all badges to check which one should be current
          final badgesResult = await _badgeRepository.getAllBadges();
          
          await badgesResult.fold(
            (failure) async {
              if (!emit.isDone) {
                emit(UserError(failure.toString()));
              }
            },
            (badges) async {
              // Get user's points
              final progressResult = await _quizRepository.getUserProgressByUserId(event.userId);
              
              await progressResult.fold(
                (failure) async {
                  if (!emit.isDone) {
                    emit(UserError(failure.toString()));
                  }
                },
                (progresses) async {
                  // Calculate total points
                  final totalPoints = progresses.fold(0, (sum, progress) => sum + (progress.points ?? 0));
                  
                  // Find highest badge based on points
                  BadgeModel? highestBadge;
                  final rankBadges = badges.where((b) => b.category == 'rank').toList();
                  rankBadges.sort((a, b) => b.requiredPoints.compareTo(a.requiredPoints));
                  
                  for (final badge in rankBadges) {
                    if (totalPoints >= badge.requiredPoints) {
                      highestBadge = badge;
                      break;
                    }
                  }

                  // Update user's badge if needed
                  if (highestBadge != null) {
                    final badgeId = highestBadge?.id;
                    if (badgeId != null) {
                      await _badgeRepository.updateUserBadge(event.userId, badgeId);
                    }
                  }

                  if (!emit.isDone) {
                    emit(UserProfileLoaded(user: user, currentBadge: highestBadge));
                  }
                },
              );
            },
          );
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(UserError(e.toString()));
      }
    }
  }

  Future<void> _onLoadUserStats(
    LoadUserStats event,
    Emitter<UserState> emit,
  ) async {
    try {
      // Get all badges to check which one should be current
      final badgesResult = await _badgeRepository.getAllBadges();
      
      badgesResult.fold(
        (failure) => emit(UserError(failure.toString())),
        (badges) async {
          // Find the highest badge the user qualifies for
          BadgeModel? highestBadge;
          final rankBadges = badges.where((b) => b.category == 'rank').toList()
            ..sort((a, b) => b.requiredPoints.compareTo(a.requiredPoints));
            
          for (final badge in rankBadges) {
            if (event.points >= badge.requiredPoints) {
              highestBadge = badge;
              break;
            }
          }
          
          if (highestBadge != null) {
            // Get current user
            final userResult = await _userRepository.getUserById(event.userId);
            
            userResult.fold(
              (failure) => emit(UserError(failure.toString())),
              (user) async {
                // Update user's badge in database
                final badgeId = highestBadge?.id;
                if (badgeId != null) {
                  await _badgeRepository.updateUserBadge(event.userId, badgeId);
                }
                emit(UserProfileLoaded(user: user, currentBadge: highestBadge));
              },
            );
          }
        },
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserPoints(
    UpdateUserPoints event,
    Emitter<UserState> emit,
  ) async {
    try {
      // Get all badges to check which one should be current
      final badgesResult = await _badgeRepository.getAllBadges();
      
      badgesResult.fold(
        (failure) => emit(UserError(failure.toString())),
        (badges) async {
          // Find the highest badge the user qualifies for
          BadgeModel? highestBadge;
          final rankBadges = badges.where((b) => b.category == 'rank').toList()
            ..sort((a, b) => b.requiredPoints.compareTo(a.requiredPoints));
            
          for (final badge in rankBadges) {
            if (event.newPoints >= badge.requiredPoints) {
              highestBadge = badge;
              break;
            }
          }
          
          if (highestBadge != null) {
            // Get current user
            final userResult = await _userRepository.getUserById(event.userId);
            
            userResult.fold(
              (failure) => emit(UserError(failure.toString())),
              (user) async {
                // Update user's badge in database
                final badgeId = highestBadge?.id;
                if (badgeId != null) {
                  await _badgeRepository.updateUserBadge(event.userId, badgeId);
                }
                emit(UserProfileLoaded(user: user, currentBadge: highestBadge));
              },
            );
          }
        },
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
