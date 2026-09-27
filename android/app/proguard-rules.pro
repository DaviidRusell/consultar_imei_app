# Mantener las clases necesarias de AndroidX WorkManager
-keep class androidx.work.** { *; }

# Específicamente evitar que se ofusque la base de datos interna de WorkManager
-keep class androidx.work.impl.WorkDatabase { *; }

# Mantener Room (ya que WorkDatabase depende de Room)
-keep class androidx.room.** { *; }
-dontwarn androidx.work.**
-dontwarn androidx.room.**
