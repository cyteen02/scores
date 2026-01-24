/*---------------------------------------------------------------------------
*
* Copyright (c) 2025 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 12/25/2025
*
*----------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:scores/data/repositories/game_repository.dart';
import 'package:scores/data/models/game.dart';
import 'package:scores/presentation/screens/game_edit_screen.dart';
//import 'package:scores/presentation/screens/game_form_screen.dart';
import 'package:scores/utils/my_utils.dart';

class ListGamesScreen extends StatefulWidget {
  
  final GameRepository gameRepository;

  const ListGamesScreen({super.key,
            required this.gameRepository});

  @override
  State<ListGamesScreen> createState() => _ListGamesScreenState();
}

class _ListGamesScreenState extends State<ListGamesScreen> {
  List<Game> games = [];
  // final dbHelper = DatabaseHelper.instance;
  late GameRepository gameRepository;
  bool isLoading = true;

  //--------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    gameRepository = widget.gameRepository;
  }

  //--------------------------------------------------------------

  //  Future<void> _loadGames() async {

  Future<Map<String, dynamic>> _fetchGamesListData() async {
    setState(() => isLoading = true);

    final loadedGames = await widget.gameRepository.getAll();

    return {'gamesList': loadedGames};
    // setState(() {
    //   games = loadedGames;
    //   debugMsg("_loadGames loaded ${games.length} games");
    //   isLoading = false;
    // });
  }

  //--------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Games'), centerTitle: true),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchGamesListData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          }

          final data = snapshot.data!;
          return _buildGamesListScreen(data);
        },
      ),
    );
  }

  //--------------------------------------------------------------
  //
  Widget _buildGamesListScreen(Map<String, dynamic> data) {
    games = data['gamesList'];

    return Scaffold(
      body: games.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.casino, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No games defined yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add someone',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return gameDismissable(game, index);
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addGame(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  //--------------------------------------------------------------

  Widget gameDismissable(Game game, int index) {
    debugMsg("gameDismissable index $index");

    return Dismissible(
      key: Key(game.name + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: Text('Are you sure you want to delete ${game.name}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'DELETE',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteGame(context, index);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          title: Text(
            game.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              game.fixedNumRounds()
                  ? Text('${game.roundLabels.length} rounds')
                  : Text('No fixed rounds'),
              Text(
                game.showFutureRoundsType.description,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue,
                ),
              ),
              Text(
                "Win condition: ${game.winCondition.description}",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _editGame(index),
        ),
        // trailing: const Icon(Icons.chevron_right),
        // onTap: () => _navigateToEdit(gameType),
      ),

      // child: ListTile(
      //   leading: player.photoPath != null
      //       ? CircleAvatar(
      //           backgroundImage: FileImage(
      //             File(player.photoPath!),
      //           ),
      //         )
      //       : CircleAvatar(
      //           backgroundColor: player.color,
      //           child: Text(
      //             player.name[0].toUpperCase(),
      //             style: const TextStyle(
      //               color: Colors.white,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //         ),
      //   title: Text(player.name),
      //   subtitle: Row(
      //     children: [
      //       Container(
      //         width: 16,
      //         height: 16,
      //         decoration: BoxDecoration(
      //           color: player.color,
      //           shape: BoxShape.circle,
      //           border: Border.all(color: Colors.grey.shade300),
      //         ),
      //       ),
      //       const SizedBox(width: 8),
      //       Text('Favourite colour'),
      //     ],
      //   ),
      //   trailing: const Icon(Icons.chevron_right),
      //   onTap: () => _editGameType(context, gameType),
      // ),
      // ),
    );
  }
  //--------------------------------------------------------------

  void _addGame(BuildContext context) async {
    // Navigate to GameScreen to create new player
    final Game? newGame = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameEditScreen(gameRepository: widget.gameRepository)),
    );

    if (newGame != null) {
      setState(() {
        games.add(newGame);
        if (mounted) {
          showPopupMessage(context, '${newGame.name} added');
        }
      });
    }
  }

  //--------------------------------------------------------------

  //  void _editGame(BuildContext context, Game game) async {
  void _editGame(int index) async {
    final Game? updatedGame = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameEditScreen(gameRepository: gameRepository,
                                  game: games[index]),
      ),
    );

    if (updatedGame != null) {
      setState(() {
        games[index] = updatedGame;
      });
      if (mounted) {
        showPopupMessage(context, '${updatedGame.name} updated');
      }
    }
  }

  //--------------------------------------------------------------

  void _deleteGame(BuildContext context, int index) {
    final game = games[index];

    // remove from screen
    setState(() {
      games.removeAt(index);
    });

    // remove from database
    gameRepository.deleteGame(game.id ?? 0);

    showPopupMessage(context, '${game.name} deleted');
  }

  //---------------------------------------------------------------------------

  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(DiagnosticsProperty<GameRepository>('gameRespository', gameRespository));
  // }

  //--------------------------------------------------------------

  // Future<void> _navigateToEdit(Game? game) async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => GameFormScreen(game: game)),
  //   );

  //   if (result == true) {
  //     final data = await _fetchGamesListData();
  //     games = data['gamesList'];
  //   }
  // }

  //--------------------------------------------------------------
}
