var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCarter();
builder.Services.AddMediatR(config =>
{
    config.RegisterServicesFromAssembly(typeof(Program).Assembly);
});
builder.Services.AddMarten(options =>
{
    options.Connection(builder.Configuration.GetConnectionString("MartenConnection")!);
    options.Schema.For<Product>();

}).UseLightweightSessions()
  .ApplyAllDatabaseChangesOnStartup();

//Add Services to the container.

var app = builder.Build();

// Configure the HTTP request pipeline.
app.MapCarter();
app.Run();
