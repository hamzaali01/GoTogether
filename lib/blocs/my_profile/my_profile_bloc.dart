import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_proj/repositories/user_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

part 'my_profile_event.dart';
part 'my_profile_state.dart';

class MyProfileBloc extends Bloc<MyProfileEvent, MyProfileState> {
  FirebaseFirestore firestore;

  MyProfileBloc({required this.firestore}) : super(MyProfileInitial()) {
    on<GetMyProfileEvent>((event, emit) async {
      emit(LoadingState());
      try {
        final userData = await UserRepository(firestore: firestore)
            .getUserById(event.userId);
        emit(LoadedState(userData));
      } catch (e) {
        emit(ErrorState('Failed to fetch profile' + e.toString()));
      }
    });

    on<SelectPictureEvent>((event, emit) async {
      try {
        _selectImage(event);
      } catch (e) {
        emit(ErrorState('Failed to select/upload image: ' + e.toString()));
      }
    });
  }

  Future<void> _selectImage(event) async {
    File? _imageFile;

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
    }

    final userId = event.userId;
    await _uploadImage(userId);

    //uploading the image

    if (_imageFile == null) {
      return;
    }

    emit(LoadingState());

    final fileName = 'profile_picture.jpg';
    final destination = 'users/$userId/$fileName';

    final storageRef = FirebaseStorage.instance.ref(destination);
    final uploadTask = storageRef.putFile(_imageFile!);
    final snapshot = await uploadTask.whenComplete(() {});
    final url = await snapshot.ref.getDownloadURL();

    final userRef = firestore.collection('users').doc(userId);
    await userRef.update({'profilePictureUrl': url});

    final userData =
        await UserRepository(firestore: firestore).getUserById(event.userId);

    emit(LoadedState(userData));
  }

  Future<void> _uploadImage(String userId) async {}
}
