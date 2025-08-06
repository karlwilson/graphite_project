#include <deal.II/base/quadrature_lib.h>
#include <deal.II/base/function.h>
#include <deal.II/base/utilities.h>

#include <deal.II/.lac/full_matrix.h>
#include <deal.II/lac/dynamic_sparsity_pattern.h>
#include <deal.II/lac/solver_cg.h>
#include <deal.II/lac/solver_gmres.h>
#include <deal.II/lac/precondition.h>
#include <deal.II/lac/affine_constraints.h>

#include <deal.II/grid/tria.h>
#include <deal.II/grid/grid_generator.h>
#include <deal.II/grid/grid_refinement.h>
#include <deal.II/grid/grid_tools.h>

#include <deal.II/grid/grid_in.h>
#include <deal.II/dofs/dof_handler.h>
#include <deal.II/dofs/dof_tools.h>

#include <deal.II/fe/fe_q.h>
#include <deal.II/fe/fe_system.h>
#include <deal.II/fe/fe_values.h>

#include <deal.II/numerics/vector_tools.h>
#include <deal.II/numerics/data_out.h>
#include <deal.II/numerics/error_estimator.h>

#include <deal.II/numerics/solution_transfer.h>

#include <deal.II/lac/sparse_direct.h>

#include <fstream>
#include <iostream>
#include <filesystem>

namespace fs = std::filesystem;

namespace jet_on_wall
{
  using namespace dealii;

  template <int dim>
  class NavierStokes
  {
  public:
  void run(const unsigned int refinement);
  NavierStokes(double viscosity, const unsigned int degree);

  private:
    void setup_system();
  
    void initialize_system(const bool initial_step);

    void assemble(const bool initial_step, const bool assemble_matrix);

    void assemble_system(const bool initial_step);

    void assemble_rhs(const bool initial_step);

    void solve();

    void refine_mesh(const bool first_step);

    void newton_iteration(const double        tolerance,
                          const unsigned int  max_n_refinements,
                          const bool          is_initial_step,
                          const bool          output_result);
    
    Triangulation<dim> triangulation;
    DoFHandler<dim> dof_handler;
    FESystem<dim> fe;
    
    SparsityPattern sparsity_pattern;
    SparseMatrix<double> system_matrix;
    
    Vector<double> solution_update;
    Vector<double> present_solution;
    Vector<double> system_rhs;

    AffineConstraints<double> zero_constraints;
    AffineConstraints<double> nonzero_constraints;

    double viscosity;
    unsigned int degree;
  };
} // namespace jet_on_wall
