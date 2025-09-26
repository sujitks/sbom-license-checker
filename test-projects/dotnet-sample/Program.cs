using System;
using Bogus;
using Newtonsoft.Json;
using Serilog;
using SkiaSharp;
using Npgsql;

namespace DotNetSample
{
    class Program
    {
        static void Main(string[] args)
        {
            // Initialize Serilog logger
            Log.Logger = new LoggerConfiguration()
                .WriteTo.Console()
                .CreateLogger();

            Log.Information("Starting DotNet SBOM Sample - SBOM Test Application");

            try
            {
                // Test Bogus for fake data generation
                TestBogusDataGeneration();

                // Test JSON serialization with Newtonsoft.Json
                TestJsonSerialization();

                // Test SkiaSharp graphics capabilities
                TestSkiaSharpGraphics();

                // Test PostgreSQL connection capability (without actual connection)
                TestNpgsqlCapability();

                Log.Information("All package tests completed successfully!");
            }
            catch (Exception ex)
            {
                Log.Error(ex, "An error occurred during testing");
            }
            finally
            {
                Log.CloseAndFlush();
            }
        }

        private static void TestBogusDataGeneration()
        {
            Log.Information("Testing Bogus data generation...");
            
            var faker = new Faker();
            var testUser = new
            {
                Name = faker.Name.FullName(),
                Email = faker.Internet.Email(),
                Address = faker.Address.FullAddress()
            };

            Log.Information("Generated test user: {User}", JsonConvert.SerializeObject(testUser, Formatting.Indented));
        }

        private static void TestJsonSerialization()
        {
            Log.Information("Testing Newtonsoft.Json serialization...");
            
            var testObject = new
            {
                Id = Guid.NewGuid(),
                CreatedAt = DateTime.UtcNow,
                Items = new[] { "Item1", "Item2", "Item3" }
            };

            var json = JsonConvert.SerializeObject(testObject, Formatting.Indented);
            Log.Information("Serialized object: {Json}", json);
        }

        private static void TestSkiaSharpGraphics()
        {
            Log.Information("Testing SkiaSharp graphics capabilities...");
            
            // Create a simple bitmap to test SkiaSharp functionality
            var imageInfo = new SKImageInfo(100, 100);
            using (var surface = SKSurface.Create(imageInfo))
            {
                var canvas = surface.Canvas;
                canvas.Clear(SKColors.White);
                
                using (var paint = new SKPaint())
                {
                    paint.Color = SKColors.Blue;
                    paint.IsAntialias = true;
                    canvas.DrawCircle(50, 50, 25, paint);
                }

                Log.Information("SkiaSharp: Created a 100x100 image with a blue circle");
            }
        }

        private static void TestNpgsqlCapability()
        {
            Log.Information("Testing Npgsql PostgreSQL driver capabilities...");
            
            // Test connection string building (without actual connection)
            var connectionStringBuilder = new NpgsqlConnectionStringBuilder
            {
                Host = "localhost",
                Database = "testdb",
                Username = "testuser",
                Password = "testpass"
            };

            Log.Information("Npgsql: Built connection string for PostgreSQL");
            Log.Information("Connection string length: {Length} characters", connectionStringBuilder.ConnectionString.Length);
        }
    }
}